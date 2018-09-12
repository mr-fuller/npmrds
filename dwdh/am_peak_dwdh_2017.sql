drop table if exists passenger_dwdh;
create table passenger_dwdh as

with determine_delay_hours as(
select i.*,
case when (i.tmc_code = t.tmc)
	then t.miles
	else o.miles
	end as miles,
	t.road,
t.direction,
t.intersection,
--t.miles as miles2,
--o.miles as miles1,
o.aadt,
	o.f_system,
	o.geom,
--60*miles/speed as travel_time_calc,
--60*miles/reference_speed as ref_travel_time,
case when (i.reference_speed*0.75 > i.speed)
  THEN 10 
  ELSE 0
end as delay_minutes

from npmrds2017passenger_10min_no_null as i
full outer join tmacog_tmcs as o on o.tmc = i.tmc_code 
full join tmc_identification as t on t.tmc = i.tmc_code
	
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
)



--am_peak as
--(
select a.tmc_code, 
a.geom,
--date_part('year', measurement_tstamp), 
a.miles,
a.road,
a.direction,
a.intersection,
a.f_system,
--a.miles2,
--avg_dwdh.avg_dwdh,
--case when (a.geom is null)
--then round(sum(a.delay_hours*a.miles2),2) 
round(sum(a.delay_minutes*a.miles),2) as amp_dwdm_2017,
round(sum(a.delay_minutes*a.miles)/(4*5*52*60)*100,2) as amp_dwdm_pct_2017

 
from determine_delay_hours a --,avg_dwdh
--join determine_delay_hours b
--on a.tmc_code = b.tmc_code
--AM Peak is 6-10 AM
where (date_part('hour', a.measurement_tstamp)  > 5 and date_part('hour', a.measurement_tstamp)  < 10) and --note hour 8 means 8:00-8:59 is what I'm assuming
 (extract(dow from measurement_tstamp )> 0 and extract(dow from measurement_tstamp ) < 6) --and
 --date_part('year', measurement_tstamp) = 2017
--and date_part('hour', b.measurement_tstamp)  > 8 and date_part('hour', b.measurement_tstamp)  < 14 --note hour 8 means 8:00-8:59 is what I'm assuming
group by a.tmc_code, a.geom, a.miles, a.road, a.direction, a.intersection, a.f_system
order by amp_dwdm_pct_2017 desc;
	
