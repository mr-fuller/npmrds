--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2016 numeric ,
add column if not exists tt_we50pct_2016 numeric,
add column if not exists tt_we80pct_2016 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds2012to2016passenger_10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.8) within group (order by travel_time_minutes) as tt_we80pct_2016,
percentile_disc(0.5) within group (order by travel_time_minutes) as tt_we50pct_2016,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2016 and
--tmc_code = '108+12989' and
--Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19) and
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6)
	group by tmc_code, geom
)

update congestion_lottr
set lottr_we_2016 = apl.lottr,
tt_we50pct_2016 = apl.tt_we50pct_2016,
tt_we80pct_2016 = apl.tt_we80pct_2016
from apl
where congestion_lottr.tmc_code = apl.tmc_code
