--drop table congestion_locations;
--create table congestion_locations as
alter table passenger_dwdm
add column if not exists we_dwdm_2017 numeric,
add column if not exists we_dwdm_pct_2017 numeric;
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
we_dwdm_2017 as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as we_dwdm_2017,
round(sum(delay_minutes*miles)/(14*2*52*60)*100,2) as we_dwdm_pct_2017
from determine_delay_hours
where
date_part('year',measurement_tstamp) = 2017 and
 --sat and sun
(extract(dow from measurement_tstamp ) = 0 or extract(dow from measurement_tstamp ) = 6) and
--6AM to 8PM
--Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19)

group by tmc_code
)

--for off Peak midnight-6AM and 6-11:59 PM

update passenger_dwdm as cl
set we_dwdm_2017 = we_dwdm_2017.we_dwdm_2017,
we_dwdm_pct_2017 = we_dwdm_2017.we_dwdm_pct_2017
from we_dwdm_2017
where cl.tmc_code = we_dwdm_2017.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
