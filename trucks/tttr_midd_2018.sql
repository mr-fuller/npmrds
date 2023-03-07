--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_midd_2018 numeric,
add column if not exists ttt_midd50pct_2018 numeric,
add column if not exists ttt_midd95pct_2018 numeric;

with


apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_midd95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_midd50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_midd

from npmrds_truck_midd_2018
	group by tmc_code --, geom
)

update tttr
set tttr_midd_2018 = apl.tttr_midd,
ttt_midd50pct_2018 = apl.ttt_midd50pct,
ttt_midd95pct_2018 = apl.ttt_midd95pct
from apl
where tttr.tmc = apl.tmc_code
