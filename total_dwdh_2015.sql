--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column total_dwdh_2015 numeric;

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
total_dwdh_2015 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as total_dwdh_2015
from determine_delay_hours
where date_part('year', measurement_tstamp) = 2015
group by tmc_code
)

--for all hours

update congestion_locations as cl
set total_dwdh_2015 = total_dwdh_2015.total_dwdh_2015
from total_dwdh_2015
where cl.tmc_code = total_dwdh_2015.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);

