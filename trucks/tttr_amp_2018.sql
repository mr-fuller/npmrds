--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_amp_2018 numeric,
add column if not exists ttt_amp50pct_2018 numeric,
add column if not exists ttt_amp95pct_2018 numeric;

with

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_amp95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_amp50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_amp

from npmrds_truck_amp_2018
	group by tmc_code--, geom
)

update tttr
set tttr_amp_2018 = apl.tttr_amp,
ttt_amp50pct_2018 = apl.ttt_amp50pct,
ttt_amp95pct_2018 = apl.ttt_amp95pct
from apl
where tttr.tmc = apl.tmc_code
