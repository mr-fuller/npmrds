--drop table congestion_locations;
--create table congestion_locations as
alter table congestion_locations
add column if not exists midday_dwdm_2016 numeric,
add column if not exists midday_dwdm_pct_2016 numeric;

with determine_delay_minutes as(
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
full outer join npmrds2012to2017data as i
on o.tmc = i.tmc_code
full join tmc_identification as t on t.tmc = i.tmc_code
--where i.cvalue > 10
--where date_part('hour', measurement_tstamp)  =  --and date_part('hour', measurement_tstamp)  <= 14
),
m_dwdh_2016 as
(select
tmc_code,
round(sum(delay_minutes*miles),2) as midday_dwdm_2016,
round(sum(delay_minutes*miles)/(6*5*52*60)*100,2) as midday_dwdm_pct_2016
from determine_delay_minutes
where (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14) and
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and --Mon-Fri
date_part('year', measurement_tstamp) = 2016
group by tmc_code
)

--for midday Peak 9AM-2PM
--am_peak as
--(
update congestion_locations
set midday_dwdm_2016 = m_dwdh_2016.midday_dwdm_2016,
midday_dwdm_pct_2016 = m_dwdh_2016.midday_dwdm_pct_2016
from m_dwdh_2016
where congestion_locations.tmc_code = m_dwdh_2016.tmc_code ;--and (date_part('hour', measurement_tstamp)  > 8 and date_part('hour', measurement_tstamp)  < 14);
