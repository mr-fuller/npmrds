--drop table congestion_locations;
--create table congestion_locations as
alter table truck_dwdh
add column if not exists amp_truck_dwdh_2014 numeric;

with determine_delay_hours as(
select i.*,
case when (i.tmc_code = t.tmc)
	then t.miles
	else o.miles
	end as miles,
o.aadt,

case when (i.reference_speed*0.75 > i.speed)
  THEN (1/6)
  ELSE 0
end as delay_hours,
o.geom
from tmacog_tmcs as o
full outer join npmrds2012to2016truck10min_no_null as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where date_part('year', i.measurement_tstamp)  =  2016 --and date_part('hour', measurement_tstamp)  <= 14
),
amp_truck_dwdh_2014 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as amp_truck_dwdh_2014
from determine_delay_hours
where (date_part('hour', measurement_tstamp)  > 5 and date_part('hour', measurement_tstamp)  < 10) and
date_part('year', measurement_tstamp) = 2014 and
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6)
group by tmc_code
)

--for am Peak 6-9AM
--am_peak as
--(
update truck_dwdh
set amp_truck_dwdh_2014 = amp_truck_dwdh_2014.amp_truck_dwdh_2014
from amp_truck_dwdh_2014
where truck_dwdh.tmc_code = amp_truck_dwdh_2014.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
