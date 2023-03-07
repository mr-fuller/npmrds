--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2021 numeric,
add column if not exists tt_we50pct_2021 numeric,
add column if not exists tt_we80pct_2021 numeric;

with


apl as (
select
tmc_code,
--geom,
percentile_disc(0.8) within group (order by travel_time_seconds) as tt_we80pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as tt_we50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from npmrds_passenger_we_2021
-- where date_part('year',measurement_tstamp) = 2021 and
--tmc_code = '108+12989' and
--Sat and Sun 6AM-8PM
	-- (date_part('hour', measurement_tstamp) between 6 and 19) and
	-- (extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6)
	group by tmc_code, geom
)

update congestion_lottr
set lottr_we_2021 = apl.lottr,
tt_we50pct_2021 = apl.tt_we50pct,
tt_we80pct_2021 = apl.tt_we80pct
from apl
where congestion_lottr.tmc_code = apl.tmc_code
