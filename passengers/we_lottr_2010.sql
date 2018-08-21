--drop table congestion_lottr;
--create table congestion_lottr as
alter table congestion_lottr
add column if not exists lottr_we_2010 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from inrix09to10data as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.5) within group (order by travel_time_minutes) as tt_we50pct_2010,
percentile_disc(0.8) within group (order by travel_time_minutes) as tt_we80pct_2010,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2)
	end as lottr

from joined
where date_part('year',measurement_tstamp) = 2010 and
--tmc_code = '108+12989' and
--Mon-Fri
((extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and
	--off Peak
	(date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 17 )) or
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6)
	group by tmc_code, geom
)

update congestion_lottr
set lottr_we_2010 = apl.lottr
from apl
where congestion_lottr.tmc_code = apl.tmc_code
