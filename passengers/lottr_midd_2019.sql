--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr_2019
add column if not exists lottr_midd_2019 numeric,
add column if not exists tt_midd50pct_2019 numeric,
add column if not exists tt_midd80pct_2019 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds_2019_passenger_seconds_nonull_10min as i
full join tmacog_tmcs_2019 as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_cont(0.8) within group (order by travel_time_seconds) as tt_midd80pct,
percentile_cont(0.5) within group (order by travel_time_seconds) as tt_midd50pct,
case when(percentile_disc(0.5) within group (order by travel_time_seconds) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2019 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 10 and 15)
	group by tmc_code, geom
)

update congestion_lottr_2019
set lottr_midd_2019 = apl.lottr,
tt_midd50pct_2019 = apl.tt_midd50pct,
tt_midd80pct_2019 = apl.tt_midd80pct
from apl
where congestion_lottr_2019.tmc = apl.tmc_code
