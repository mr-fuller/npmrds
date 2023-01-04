--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr_2020
add column if not exists tttr_ovn_2020 numeric,
add column if not exists ttt_ovn50pct_2020 numeric,
add column if not exists ttt_ovn95pct_2020 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds_2020_inrix_truck_seconds_nonull_10min as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_ovn95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_ovn50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_ovn

from joined
where date_part('year',measurement_tstamp) = 2020 and
--tmc_code = '108+12989' and
--overnight is 8 PM to 6 AM every day of the week
(date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 19 )
	group by tmc_code, geom
)

update tttr_2020
set tttr_ovn_2020 = apl.tttr_ovn,
ttt_ovn50pct_2020 = apl.ttt_ovn50pct,
ttt_ovn95pct_2020 = apl.ttt_ovn95pct
from apl
where tttr_2020.tmc = apl.tmc_code
