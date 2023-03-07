--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_midd_2020 numeric,
add column if not exists tt_midd50pct_2020 numeric,
add column if not exists tt_midd80pct_2020 numeric;

with


apl as (
select
tmc_code,
--geom,
percentile_cont(0.8) within group (order by travel_time_seconds) as tt_midd80pct,
percentile_cont(0.5) within group (order by travel_time_seconds) as tt_midd50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from npmrds_passenger_midd_2020
	group by tmc_code, geom
)

update congestion_lottr
set lottr_midd_2020 = apl.lottr,
tt_midd50pct_2020 = apl.tt_midd50pct,
tt_midd80pct_2020 = apl.tt_midd80pct
from apl
where congestion_lottr.tmc_code = apl.tmc_code
