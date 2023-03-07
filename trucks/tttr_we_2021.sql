
alter table tttr
add column if not exists tttr_we_2021 numeric,
add column if not exists ttt_we50pct_2021 numeric,
add column if not exists ttt_we95pct_2021 numeric;

with

apl as (
select
tmc_code,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_we95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_we50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_we

from npmrds_truck_we_2021
	group by tmc_code
)

update tttr
set tttr_we_2021 = apl.tttr_we,
ttt_we50pct_2021 = apl.ttt_we50pct,
ttt_we95pct_2021 = apl.ttt_we95pct
from apl
where tttr.tmc = apl.tmc_code
