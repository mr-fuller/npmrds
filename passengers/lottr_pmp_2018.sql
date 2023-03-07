--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_pmp_2018 numeric,
add column if not exists tt_pmp50pct_2018 numeric,
add column if not exists tt_pmp80pct_2018 numeric;

with


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

from npmrds_passenger_pmp_2018

	group by tmc_code--, geom
)

update congestion_lottr
set lottr_pmp_2018 = apl.lottr,
tt_pmp50pct_2018 = apl.tt_pmp50pct,
tt_pmp80pct_2018 = apl.tt_pmp80pct
from apl
where congestion_lottr.tmc_code = apl.tmc_code
