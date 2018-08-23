--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2017 numeric,
add column if not exists tt_we50pct_2017 numeric,
add column if not exists tt_we80pct_2017 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from inrix2017data as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.8) within group (order by travel_time_minutes) as tt_we80pct_2017,
percentile_disc(0.5) within group (order by travel_time_minutes) as tt_we50pct_2017,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2017 and
--tmc_code = '108+12989' and
--Sat and Sun 6AM-8PM

	--off Peak
	(date_part('hour', measurement_tstamp)  > 5 or date_part('hour', measurement_tstamp)  < 20 ) and
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6)
	group by tmc_code, geom
)

update congestion_lottr
set lottr_we_2017 = apl.lottr,
set tt_we50pct_2017 = apl.tt_we50pct_2017,
set tt_we80pct_2017 = apl.tt_we80pct_2017
from apl
where congestion_lottr.tmc_code = apl.tmc_code