--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column if not exists midday_dwdh_2014 numeric;

with determine_delay_hours as(
select i.*,
case when (i.tmc_code = t.tmc)
	then t.miles
	else o.miles
	end as miles,
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
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
midday_dwdh_2014 as
(select
tmc_code,
round(sum(delay_hours*miles),2) as midday_dwdh_2014
from determine_delay_hours
where (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14) and 
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and --Mon-Fri
date_part('year',measurement_tstamp) = 2014
group by tmc_code
)

--for midday Peak 9AM-2PM
--am_peak as
--(
update congestion_locations as cl
set midday_dwdh_2014 = midday_dwdh_2014.midday_dwdh_2014
from midday_dwdh_2014
where cl.tmc_code = midday_dwdh_2014.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);


