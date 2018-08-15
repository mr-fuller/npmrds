--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists am_peak_lottr_2013 numeric;

with 
joined as(
	
select i.*,
g.miles,
g.geom
from inrix11to13data as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
--percentile_disc(0.8) within group (order by travel_time_minutes) as percentile_eighty_2016,
--percentile_disc(0.5) within group (order by travel_time_minutes) as percentile_fifty_2016,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2) 
	end as am_peak_lottr_2013

from joined
where date_part('year',measurement_tstamp) = 2013 and  
--tmc_code = '108+12989' and 
--Mon-Fri
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and 
	--AM Peak
	(date_part('hour',measurement_tstamp) > 5 and date_part('hour',measurement_tstamp) < 9)
	group by tmc_code, geom
)

update congestion_lottr
set am_peak_lottr_2013 = apl.am_peak_lottr_2013
from apl
where congestion_lottr.tmc_code = apl.tmc_code