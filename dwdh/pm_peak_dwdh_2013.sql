--drop table passenger_dwdm;
--create table passenger_dwdm as
alter table passenger_dwdm
add column if not exists pmp_dwdm_2013 numeric,
add column if not exists pmp_dwdm_pct_2013 numeric;

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
full outer join npmrds2012to2016passenger_10min_no_null as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
pmp_dwdm_2013 as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as pmp_dwdm_2013,
round(sum(delay_minutes*miles)/(4*5*52*60)*100,2) as pmp_dwdm_pct_2013
from determine_delay_hours
where (date_part('hour',measurement_tstamp) between 16 and 19) and
(extract(dow from measurement_tstamp ) between 1 and 5) and--Mon-Fri
date_part('year', measurement_tstamp) = 2013
group by tmc_code
)

--for pm Peak 2-6PM

update passenger_dwdm as cl
set pmp_dwdm_2013 = pmp_dwdm_2013.pmp_dwdm_2013,
pmp_dwdm_pct_2013 = pmp_dwdm_2013.pmp_dwdm_pct_2013
from pmp_dwdm_2013
where cl.tmc_code = pmp_dwdm_2013.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
