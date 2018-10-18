--drop table passenger_dwdm;
--create table passenger_dwdm as
alter table passenger_dwdm
add column if not exists amp_dwdm_2014 numeric,
add column if not exists amp_dwdm_pct_2014 numeric;

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
end as delay_hours,
o.geom
from tmacog_tmcs as o
full outer join npmrds2012to2016passenger_10min_no_null as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where date_part('year', i.measurement_tstamp)  =  2016 --and date_part('hour', measurement_tstamp)  <= 14
),
amp_dwdm_2014 as
(select
tmc_code,
round(sum(a.delay_minutes*a.miles),2) as amp_dwdm_2014,
round(sum(a.delay_minutes*a.miles)/(4*5*52*60)*100,2) as amp_dwdm_pct_2014
from determine_delay_hours
where (date_part('hour', measurement_tstamp)  > 5 and date_part('hour', measurement_tstamp)  < 9) and
date_part('year', measurement_tstamp) = 2014 and
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6)
group by tmc_code
)

--for am Peak 6-9AM
--am_peak as
--(
update passenger_dwdm
set amp_dwdm_2014 = amp_dwdm_2014.amp_dwdm_2014,
amp_dwdm_pct_2014 = amp_dwdm_2014.amp_dwdm_pct_2014
from amp_dwdm_2014
where passenger_dwdm.tmc_code = amp_dwdm_2014.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
