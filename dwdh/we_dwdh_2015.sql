--drop table passenger_dwdm;
--create table passenger_dwdm as
alter table passenger_dwdm
add column if not exists we_dwdm_2015 numeric,
add column if not exists we_dwdm_pct_2015 numeric;
update passenger_dwdm
set we_dwdm_2015 = null;

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
we_dwdm_2015 as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as we_dwdm_2015,
round(sum(delay_minutes*miles)/(14*2*52*60)*100,2) as we_dwdm_pct_2015
from determine_delay_hours
whereminutes
date_part('year',measurement_tstamp) = 2015 and
 --sat and sun
(extract(dow from measurement_tstamp ) = 0 or extract(dow from measurement_tstamp ) = 6) and
--6AM to 8PM
--Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19)
group by tmc_code
)

--for off Peak midnight-6AM and 6-11:59 PM

update passenger_dwdm as cl
set we_dwdm_2015 = we_dwdm_2015.we_dwdm_2015,
we_dwdm_pct_2015 = we_dwdm_2015.we_dwdm_pct_2015
from we_dwdm_2015
where cl.tmc_code = we_dwdm_2015.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
