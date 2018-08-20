drop table congestion_lottr;
create table congestion_lottr as

with 
joined as(
	
select i.*,
g.*
from inrix2017data as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
)


select
tmc_code,
geom,
percentile_disc(0.8) within group (order by travel_time_minutes) as percentile_eighty_2017,
percentile_disc(0.5) within group (order by travel_time_minutes) as percentile_fifty_2017,
round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2) as am_peak_lottr_2017

from joined
where 
--tmc_code = '108+12989' and 
--Mon-Fri
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and 
	--AM Peak
	(date_part('hour',measurement_tstamp) > 5 and date_part('hour',measurement_tstamp) < 9)
	group by tmc_code, geom;
