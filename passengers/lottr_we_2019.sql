--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2019 numeric,
add column if not exists tt_we50pct_2019 numeric,
add column if not exists tt_we80pct_2019 numeric;

with


apl as (
select
tmc_code,
--geom,
percentile_disc(0.8) within group (order by travel_time_seconds) as tt_we80pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as tt_we50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from npmrds_passenger_we_2019
	group by tmc_code --, geom
)

update congestion_lottr
set lottr_we_2019 = apl.lottr,
tt_we50pct_2019 = apl.tt_we50pct,
tt_we80pct_2019 = apl.tt_we80pct
from apl
where congestion_lottr.tmc_code = apl.tmc_code

\echo 'LOTTR 2019 Weekend complete at '`date`