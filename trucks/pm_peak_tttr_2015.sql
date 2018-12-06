--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_pmp_2015 numeric,
add column if not exists ttt_pmp50pct_2015 numeric,
add column if not exists ttt_pmp95pct_2015 numeric;

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
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds) as numeric),0) as ttt_pmp95pct_2015,
round(cast(percentile_disc(0.5) within group (order by travel_time_seconds) as numeric), 0) as ttt_pmp50pct_2015,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as tttr

from joined
where date_part('year',measurement_tstamp) = 2015 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--PM Peak
	(date_part('hour',measurement_tstamp) between 16 and 19)
	group by tmc_code, geom
)

update tttr
set tttr_pmp_2015 = apl.tttr,
ttt_pmp50pct_2015 = apl.ttt_pmp50pct_2015,
ttt_pmp95pct_2015 = apl.ttt_pmp95pct_2015
from apl
where tttr.tmc_code = apl.tmc_code
