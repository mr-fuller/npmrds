
alter table tttr
add column if not exists tttr_ovn_2020 numeric,
add column if not exists ttt_ovn50pct_2020 numeric,
add column if not exists ttt_ovn95pct_2020 numeric;

with


apl as (
select
tmc_code,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_ovn95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_ovn50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_ovn

from npmrds_truck_ovn_2020
	group by tmc_code
)

update tttr
set tttr_ovn_2020 = apl.tttr_ovn,
ttt_ovn50pct_2020 = apl.ttt_ovn50pct,
ttt_ovn95pct_2020 = apl.ttt_ovn95pct
from apl
where tttr.tmc = apl.tmc_code
