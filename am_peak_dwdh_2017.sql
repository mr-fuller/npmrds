drop table congestion_locations;
create table congestion_locations as

with determine_delay_hours as(
select i.*,
o.miles,
o.aadt,
--60*miles/speed as travel_time_calc,
--60*miles/reference_speed as ref_travel_time,
case when (i.reference_speed*0.75 > i.speed)
  THEN 1 
  ELSE 0
end as delay_hours,
o.geom
from ohio as o
join inrix2017data as i
on o.tmc = i.tmc_code 
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
)


--for am Peak 6-9AM
--am_peak as
--(
select a.tmc_code, 
--date_part('year', measurement_tstamp), 
a.miles, 
--avg_dwdh.avg_dwdh,
round(sum(a.delay_hours*a.miles),2) as am_peak_dwdh_2017,
--ound(sum(b.delay_hours*b.miles),2) as midday_dwdh_2017,
/*case when (sum(delay_hours*miles) < avg_dwdh.avg_dwdh) 
	then (avg_dwdh.avg_dwdh - sum(delay_hours*miles))*(100/avg_dwdh.avg_dwdh )
    else (sum(delay_hours*miles)-(avg_dwdh.avg_dwdh))*(100/avg_dwdh.avg_dwdh ) 
	end as dhaa,*/
a.geom 
from determine_delay_hours a --,avg_dwdh
--join determine_delay_hours b
--on a.tmc_code = b.tmc_code
where date_part('hour', a.measurement_tstamp)  > 5 and date_part('hour', a.measurement_tstamp)  < 9 --note hour 8 means 8:00-8:59 is what I'm assuming
--and date_part('hour', b.measurement_tstamp)  > 8 and date_part('hour', b.measurement_tstamp)  < 14 --note hour 8 means 8:00-8:59 is what I'm assuming
group by a.tmc_code, a.geom, a.miles;--, avg_dwdh.avg_dwdh
	/*)
select
am_peak.tmc_code,
am_peak_dwdh_2017,
--midday_dwdh_2017,
--pm_peak_dwdh_2017,
--off_peak_dwdh_2017,
am_peak.geom
into congestion_locations
from determine_delay_hours, am_peak;--, midday_peak, pm_peak, off_peak
--group by am_peak.tmc_code;--, date_part('year',measurement_tstamp),am_peak.geom, ;*/