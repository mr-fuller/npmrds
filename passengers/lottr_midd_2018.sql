--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_midd_2018 numeric,
add column if not exists tt_midd50pct_2018 numeric,
add column if not exists tt_midd80pct_2018 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds_2018_passenger_seconds_nonull_10min as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.8) within group (order by travel_time_seconds) as tt_midd80pct,
percentile_disc(0.5) within group (order by travel_time_seconds) as tt_midd50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2018 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 10 and 15)
	group by tmc_code, geom
)

update congestion_lottr
set lottr_midd_2018 = apl.lottr,
tt_midd50pct_2018 = apl.tt_midd50pct,
tt_midd80pct_2018 = apl.tt_midd80pct
from apl
where congestion_lottr.tmc_code = apl.tmc_code
