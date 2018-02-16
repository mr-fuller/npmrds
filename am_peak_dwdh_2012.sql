--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column am_peak_dwdh_2012 numeric;

with determine_delay_hours as(
select i.*,
o.miles,
o.aadt,

case when (i.reference_speed*0.75 > i.speed)
  THEN 1 
  ELSE 0
end as delay_hours,
o.geom
from ohio as o
join inrix11to13data as i
on o.tmc = i.tmc_code 

--where date_part('year', i.measurement_tstamp)  =  2016 --and date_part('hour', measurement_tstamp)  <= 14
),
am_peak_dwdh_2012 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as am_peak_dwdh_2012
from determine_delay_hours
where date_part('hour', measurement_tstamp)  > 5 and date_part('hour', measurement_tstamp)  < 9 and date_part('year', measurement_tstamp) = 2012
group by tmc_code
)

--for am Peak 6-9AM
--am_peak as
--(
update congestion_locations as cl
set am_peak_dwdh_2012 = am_peak_dwdh_2012.am_peak_dwdh_2012
from am_peak_dwdh_2012
where cl.tmc_code = am_peak_dwdh_2012.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);


