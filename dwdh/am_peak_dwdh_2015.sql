--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column if not exists am_peak_dwdh_2015 numeric;

with determine_delay_hours as(
select i.*,
case when (i.tmc_code = t.tmc)
	then t.miles
	else o.miles
	end as miles,
--o.miles,
o.aadt,

case when (i.reference_speed*0.75 > i.speed)
  THEN 1 
  ELSE 0
end as delay_hours,
o.geom
from tmacog_tmcs as o
full outer join npmrds2012to2017data as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code 

--where date_part('year', i.measurement_tstamp)  =  2016 --and date_part('hour', measurement_tstamp)  <= 14
),
am_peak_dwdh_2015 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as am_peak_dwdh_2015
from determine_delay_hours
where (date_part('hour', measurement_tstamp)  > 5 and date_part('hour', measurement_tstamp)  < 9 ) and 
date_part('year', measurement_tstamp) = 2015 and
(extract(dow from measurement_tstamp )> 0 and extract(dow from measurement_tstamp ) < 6) --mon-fri

group by tmc_code
)

--for am Peak 6-9AM
--am_peak as
--(
update congestion_locations 
set am_peak_dwdh_2015 = am_peak_dwdh_2015.am_peak_dwdh_2015
from am_peak_dwdh_2015
where congestion_locations.tmc_code = am_peak_dwdh_2015.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);

