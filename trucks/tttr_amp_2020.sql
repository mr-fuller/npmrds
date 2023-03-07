--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_amp_2020 numeric,
add column if not exists ttt_amp50pct_2020 numeric,
add column if not exists ttt_amp95pct_2020 numeric;
create index if not exists idx_t_amp_2020 on tttr (tttr_amp_2020, ttt_amp50pct_2020, ttt_amp95pct_2020);

with


apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_amp95pct,
\echo '2020 AM Peak 95th percentile found at ' `date`
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_amp50pct,
\echo '2020 AM Peak 50th percentile found at ' `date`
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_amp
--round(cast(ttt_amp95pct/ttt_amp50pct as numeric),2) as tttr_amp
\echo '2020 AM Peak TTTR found at ' `date`
from npmrds_truck_amp_2020
	group by tmc_code--, geom
)

update tttr
set tttr_amp_2020 = apl.tttr_amp,
ttt_amp50pct_2020 = apl.ttt_amp50pct,
ttt_amp95pct_2020 = apl.ttt_amp95pct
from apl
where tttr.tmc = apl.tmc_code
