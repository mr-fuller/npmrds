--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column off_peak_dwdh_2014 numeric;

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
join inrix14to16data as i
on o.tmc = i.tmc_code 
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
off_peak_dwdh_2014 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as off_peak_dwdh_2014
from determine_delay_hours
where (date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 17) and date_part('year', measurement_tstamp) = 2014
group by tmc_code
)

--for off Peak midnight-6AM and 6-11:59 PM

update congestion_locations as cl
set off_peak_dwdh_2014 = off_peak_dwdh_2014.off_peak_dwdh_2014
from off_peak_dwdh_2014
where cl.tmc_code = off_peak_dwdh_2014.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);


