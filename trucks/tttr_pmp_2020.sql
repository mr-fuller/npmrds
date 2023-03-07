--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_pmp_2020 numeric,
add column if not exists ttt_pmp50pct_2020 numeric,
add column if not exists ttt_pmp95pct_2020 numeric;

with

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_pmp95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_pmp50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_pmp

from npmrds_truck_pmp_2020
	group by tmc_code --, geom
)

update tttr
set tttr_pmp_2020 = apl.tttr_pmp,
ttt_pmp50pct_2020 = apl.ttt_pmp50pct,
ttt_pmp95pct_2020 = apl.ttt_pmp95pct
from apl
where tttr.tmc = apl.tmc_code
