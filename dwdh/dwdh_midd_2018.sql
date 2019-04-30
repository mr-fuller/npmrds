--drop table passenger_dwdm;
--create table passenger_dwdm as
alter table passenger_dwdm_2018
add column if not exists dwdm_midd_2018 numeric,
add column if not exists dwdm_pct_midd_2018 numeric;

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
from tmacog_tmcs_2018 as o
full outer join npmrds_2018_passenger_seconds_nonull_10min as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
dwdm as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as midd_dwdm,
round(sum(delay_minutes*miles)/(6*5*52*60*a.miles)*100,2) as midd_dwdm_pct
from determine_delay_hours
where (date_part('hour',measurement_tstamp) between 10 and 15) and
date_part('year',measurement_tstamp) = 2018 and
(extract(dow from measurement_tstamp ) between 1 and 5) --Mon-Fri
group by tmc_code
)

--for midday Peak 9AM-2PM
--am_peak as
--(
update passenger_dwdm_2018 as cl
set dwdm_midd_2018 = dwdm.midd_dwdm,
dwdm_pct_midd_2018 = dwdm.midd_dwdm_pct
from dwdm
where cl.tmc = dwdm.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
