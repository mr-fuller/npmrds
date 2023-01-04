--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr_2020
add column if not exists tttr_we_2020 numeric,
add column if not exists ttt_we50pct_2020 numeric,
add column if not exists ttt_we95pct_2020 numeric;

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
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_we95pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_we50pct,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_we

from joined
where date_part('year',measurement_tstamp) = 2020 and
--tmc_code = '108+12989' and
--Sat and Sun
(extract(dow from measurement_tstamp ) = 0 or extract(dow from measurement_tstamp ) = 6) and

--6 AM to 8 PM
(date_part('hour', measurement_tstamp) between 6 and 19)
	group by tmc_code, geom
)

update tttr_2020
set tttr_we_2020 = apl.tttr_we,
ttt_we50pct_2020 = apl.ttt_we50pct,
ttt_we95pct_2020 = apl.ttt_we95pct
from apl
where tttr_2020.tmc = apl.tmc_code
