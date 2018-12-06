--drop table tttr;
--create table tttr as
alter table tttr
add column if not exists tttr_we_2016 numeric,
add column if not exists ttt_we50pct_2016 numeric,
add column if not exists ttt_we95pct_2016 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds2012to2016truck10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_we95pct_2016,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_we50pct_2016,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as tttr

from joined
where date_part('year',measurement_tstamp) = 2016 and
--tmc_code = '108+12989' and
--Sat and Sun
(extract(dow from measurement_tstamp ) = 0 or extract(dow from measurement_tstamp ) = 6) and

	--6AM to 8 PM every day of the week
	(date_part('hour', measurement_tstamp) between 6 and 19)
	group by tmc_code, geom
)

update tttr
set tttr_we_2016 = apl.tttr,
ttt_we50pct_2016 = apl.ttt_we50pct_2016,
ttt_we95pct_2016 = apl.ttt_we95pct_2016
from apl
where tttr.tmc_code = apl.tmc_code
