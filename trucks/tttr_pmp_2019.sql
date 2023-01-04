--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr_2019
add column if not exists tttr_pmp_2019 numeric,
add column if not exists ttt_pmp50pct_2019 numeric,
add column if not exists ttt_pmp95pct_2019 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds_2019_inrix_truck_seconds_nonull_10min as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_pmp95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_pmp50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_pmp

from joined
where date_part('year',measurement_tstamp) = 2019 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 16 and 19)
	group by tmc_code, geom
)

update tttr_2019
set tttr_pmp_2019 = apl.tttr_pmp,
ttt_pmp50pct_2019 = apl.ttt_pmp50pct,
ttt_pmp95pct_2019 = apl.ttt_pmp95pct
from apl
where tttr_2019.tmc = apl.tmc_code
