--drop table passenger_dwdm_2018;
--create table passenger_dwdm_2018 as
alter table passenger_dwdm_2018
add column if not exists dwdm_pmp_2018 numeric,
add column if not exists dwdm_pct_pmp_2018 numeric;

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
round(sum(delay_minutes*miles),2) as dwdm_pmp,
round(sum(delay_minutes*miles)/(4*5*52*60)*100,2) as dwdm_pct_pmp
from determine_delay_hours
where
(extract(dow from measurement_tstamp ) between 1 and 5) and--Mon-Fri
date_part('year',measurement_tstamp) = 2018 and
(date_part('hour',measurement_tstamp) between 16 and 19) --4-8PM
group by tmc_code
)

--for pm Peak 2-6PM

update passenger_dwdm_2018 as cl
set dwdm_pmp_2018 = dwdm.dwdm_pmp,
dwdm_pct_pmp_2018 = dwdm.dwdm_pct_pmp
from dwdm
where cl.tmc = dwdm.tmc_code ;
