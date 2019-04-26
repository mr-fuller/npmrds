--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists am_peak_lottr_2016 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds2012to2016passenger_10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
--percentile_disc(0.8) within group (order by travel_time_minutes) as percentile_eighty_2016,
--percentile_disc(0.5) within group (order by travel_time_minutes) as percentile_fifty_2016,
round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2) as am_peak_lottr_2016

from joined
where date_part('year',measurement_tstamp) = 2016 and
--tmc_code = '108+12989' and
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 6 and 9)
	group by tmc_code, geom
)

update congestion_lottr
set am_peak_lottr_2016 = apl.am_peak_lottr_2016
from apl
where congestion_lottr.tmc_code = apl.tmc_code