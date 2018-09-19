--drop table congestion_lottr;
--create table congestion_lottr as
alter table tttr
add column if not exists tttr_amp_2016 numeric,
add column if not exists ttt_amp50pct_2016 numeric,
add column if not exists ttt_amp95pct_2016 numeric;

with
joined as(

select i.*,
g.miles,
g.geom
from npmrds2012to2016truck10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),

apl as (
select
tmc_code,
--geom,
percentile_disc(0.95) within group (order by travel_time_seconds) as ttt_amp95pct_2016,
percentile_disc(0.5) within group (order by travel_time_seconds) as ttt_amp50pct_2016,
round(cast(percentile_disc(0.95) within group (order by travel_time_seconds)/percentile_disc(0.5) within group (order by travel_time_seconds) as numeric),2) as tttr_amp_2016

from joined
where date_part('year',measurement_tstamp) = 2016 and
--tmc_code = '108+12989' and
--Mon-Fri
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and
	--AM Peak
	(date_part('hour',measurement_tstamp) > 5 and date_part('hour',measurement_tstamp) < 10)
	group by tmc_code, geom
)

update tttr
set tttr_amp_2016 = apl.tttr_amp_2016,
ttt_amp50pct_2016 = apl.ttt_amp50pct_2016,
ttt_amp95pct_2016 = apl.ttt_amp95pct_2016
from apl
where tttr.tmc_code = apl.tmc_code
