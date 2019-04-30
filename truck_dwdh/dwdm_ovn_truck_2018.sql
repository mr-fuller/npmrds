--drop table truck_dwdh;
--create table truck_dwdh as
alter table truck_dwdm_2018
add column if not exists dwdm_ovn_2018 numeric,
add column if not exists dwdm_pct_ovn_2018 numeric;

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
full outer join npmrds_2018_inrix_truck_seconds_nonull_10min as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
dwdm as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as dwdm_ovn,
round(sum(delay_minutes*miles)/(10*7*52*60*miles)*100,2) as dwdm_pct_ovn
from determine_delay_hours
where date_part('year',measurement_tstamp) = 2018
and (date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 19 )

group by tmc_code, miles
)

--for all hours

update truck_dwdm_2018 as cl
set dwdm_ovn_2018 = dwdm.dwdm_ovn,
dwdm_pct_ovn_2018 = dwdm.dwdm_pct_ovn
from dwdm
where cl.tmc = dwdm.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
