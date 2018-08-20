drop table if exists tttr;
create table tttr as

with 
joined as(
	
select i.*,
g.*
from npmrds2017truck10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
)


select
tmc_code,
geom,
percentile_disc(0.5) within group (order by travel_time) as ttt_amp50pct_2017,
percentile_disc(0.95) within group (order by travel_time) as ttt_amp95pct_2017,
round(cast(percentile_disc(0.95) within group (order by travel_time)/percentile_disc(0.5) within group (order by travel_time) as numeric),2) as tttr_amp_2017

from joined
where 
--tmc_code = '108+12989' and 
--Mon-Fri
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and 
	--AM Peak
	(date_part('hour',measurement_tstamp) > 5 and date_part('hour',measurement_tstamp) < 9)
	group by tmc_code, geom;
