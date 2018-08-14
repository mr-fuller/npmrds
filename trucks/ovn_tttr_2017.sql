--drop table tttr;
--create table tttr as
alter table tttr
add column if not exists tttr_ovn_2017 numeric,
add column if not exists ttt_ovn50pct_2017 numeric,
add column if not exists ttt_ovn95pct_2017 numeric;
with 
joined as(
	
select i.*,
g.miles,
g.geom
from npmrds2017truck10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time) as ttt_ovn95pct_2017,
percentile_disc(0.5) within group (order by travel_time) as ttt_ovn50pct_2017,
case when(percentile_disc(0.5) within group (order by travel_time) = 0)
	then null
	else round(cast(percentile_disc(0.95) within group (order by travel_time)/percentile_disc(0.5) within group (order by travel_time) as numeric),2) 
	end as tttr

from joined
where date_part('year',measurement_tstamp) = 2017 and  
--tmc_code = '108+12989' and 
--Mon-Fri


	--overnight is 8 PM to 6 AM every day of the week
	(date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 18 )
	
	group by tmc_code, geom
)

update tttr
set tttr_ovn_2017 = apl.tttr,
ttt_ovn50pct_2017 = apl.ttt_ovn50pct_2017,
ttt_ovn95pct_2017 = apl.ttt_ovn95pct_2017
from apl
where tttr.tmc_code = apl.tmc_code