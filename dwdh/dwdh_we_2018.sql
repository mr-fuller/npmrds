--drop table congestion_locations;
--create table congestion_locations as
alter table passenger_dwdm_2018
add column if not exists dwdm_we_2018 numeric,
add column if not exists dwdm_pct_we_2018 numeric;
--reset column to clear data from previous queries
--update congestion_locations
--set off_peak_dwdm_2013 = null;

with determine_delay_hours as(
select i.*,
case when (i.tmc_code = t.tmc)
	then t.miles
	else o.miles
	end as miles,
o.aadt,

case when (i.reference_speed*0.75 > i.speed)
  THEN 10
  ELSE 0
end as delay_minutes,
o.geom
from tmacog_tmcs as o
full outer join npmrds_2018_passenger_seconds_nonull_10min as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
dwdm as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as dwdm_we,
round(sum(delay_minutes*miles)/(14*2*52*60*miles)*100,2) as dwdm_pct_we
from determine_delay_hours
where
date_part('year',measurement_tstamp) = 2018 and
 --sat and sun
(extract(dow from measurement_tstamp ) = 0 or extract(dow from measurement_tstamp ) = 6) and
--6AM to 8PM
--Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19)

group by tmc_code
)

--for off Peak midnight-6AM and 6-11:59 PM

update passenger_dwdm_2018 as cl
set dwdm_we_2018 = dwdm.dwdm_we,
dwdm_pct_we_2018 = dwdm.dwdm_pct_we
from dwdm
where cl.tmc = dwdm.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
