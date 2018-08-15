--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists total_lottr_2016 numeric;

with 
joined as(
	
select i.*,
g.miles,
g.geom
from inrix14to16data as i
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
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2016   
--tmc_code = '108+12989' and 
--Mon-Fri
--(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and 
	--PM Peak
	--(date_part('hour',measurement_tstamp) > 13 and date_part('hour',measurement_tstamp) < 18)
	group by tmc_code, geom
)

update congestion_lottr
set total_lottr_2016 = apl.lottr
from apl
where congestion_lottr.tmc_code = apl.tmc_code