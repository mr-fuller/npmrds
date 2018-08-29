--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2011 numeric,
add column if not exists tt_we50pct_2011 numeric,
add column if not exists tt_we80pct_2011 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from inrix11to13data as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.5) within group (order by travel_time_minutes) as tt_we50pct_2011,
percentile_disc(0.8) within group (order by travel_time_minutes) as tt_we80pct_2011,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2011 and
--tmc_code = '108+12989' and
--8AM to 6PM Sat and Sunday

	--off Peak
	(date_part('hour', measurement_tstamp)  > 5 or date_part('hour', measurement_tstamp)  < 20 ) and
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6)
	group by tmc_code, geom
)

update congestion_lottr
set tt_we50pct_2011 = apl.tt_we50pct_2011,
tt_we80pct_2011 = apl.tt_we80pct_2011,
lottr_we_2011 = apl.lottr
from apl
where congestion_lottr.tmc_code = apl.tmc_code
