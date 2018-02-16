--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column midday_dwdh_2011 numeric;

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
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
midday_dwdh_2011 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as midday_dwdh_2011
from determine_delay_hours
where date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14 and date_part('year', measurement_tstamp) = 2011
group by tmc_code
)

--for midday Peak 9AM-2PM
--am_peak as
--(
update congestion_locations as cl
set midday_dwdh_2011 = midday_dwdh_2011.midday_dwdh_2011
from midday_dwdh_2011
where cl.tmc_code = midday_dwdh_2011.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);




