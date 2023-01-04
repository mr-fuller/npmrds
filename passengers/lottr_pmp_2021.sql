--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr_2021
add column if not exists lottr_pmp_2021 numeric,
add column if not exists tt_pmp50pct_2021 numeric,
add column if not exists tt_pmp80pct_2021 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds_2021_passenger_seconds_nonull_10min as i
full join tmacog_tmcs_2021 as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_cont(0.8) within group (order by travel_time_seconds) as tt_pmp80pct,
percentile_cont(0.5) within group (order by travel_time_seconds) as tt_pmp50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2021 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--PM Peak 4-8
	(date_part('hour',measurement_tstamp) between 16 and 19)
	group by tmc_code, geom
)

update congestion_lottr_2021
set lottr_pmp_2021 = apl.lottr,
tt_pmp50pct_2021 = apl.tt_pmp50pct,
tt_pmp80pct_2021 = apl.tt_pmp80pct
from apl
where congestion_lottr_2021.tmc = apl.tmc_code
