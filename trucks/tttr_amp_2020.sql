--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr_2020
add column if not exists tttr_amp_2020 numeric,
add column if not exists ttt_amp50pct_2020 numeric,
add column if not exists ttt_amp95pct_2020 numeric;

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
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_amp95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_amp50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_amp

from joined
where date_part('year',measurement_tstamp) = 2020 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 6 and 9)
	group by tmc_code, geom
)

update tttr_2020
set tttr_amp_2020 = apl.tttr_amp,
ttt_amp50pct_2020 = apl.ttt_amp50pct,
ttt_amp95pct_2020 = apl.ttt_amp95pct
from apl
where tttr_2020.tmc = apl.tmc_code
