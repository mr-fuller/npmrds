--drop table tttr;
--create table tttr as
alter table tttr
add column if not exists tttr_ovn_2015 numeric,
add column if not exists ttt_ovn50pct_2015 numeric,
add column if not exists ttt_ovn95pct_2015 numeric;

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
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_ovn95pct_2015,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_ovn50pct_2015,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) 
	end as tttr

from joined
where date_part('year',measurement_tstamp) = 2015 and  
--tmc_code = '108+12989' and 


	--overnight is 8 PM to 6AM every day of the week
	(date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 19 )
	group by tmc_code, geom
)

update tttr
set tttr_ovn_2015 = apl.tttr,
ttt_ovn50pct_2015 = apl.ttt_ovn50pct_2015,
ttt_ovn95pct_2015 = apl.ttt_ovn95pct_2015
from apl
where tttr.tmc_code = apl.tmc_code