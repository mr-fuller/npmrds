drop table congestion_lottr;
create table congestion_lottr;

alter table congestion_lottr
add column if not exists lottr_amp_2017 numeric,
add column if not exists tt_amp50pct_2017 numeric,
add column if not exists tt_amp80pct_2017 numeric;

with
joined as(

select i.*,
g.*
from npmrds2017passenger_10min_no_null as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),


apl as (
select
geom,
year_record,
	case when (state = 'Ohio')
	then '39'
	else '26'
	end as state_code
tmc_code as travel_time_code,
	f_system,
	urban_code,
	faciltype as facility_type,
	nhs,
	round(miles,3) as segment_length,
	case when (direction = 'N') then 1
	 when (direction = 'S') then 2
	 when (direction = 'E') then 3
	 when (direction = 'W') then 4
	else 5
	end as	directionality,
	round(aadt/faciltype,2) as dir_aadt,

percentile_disc(0.8) within group (order by travel_time_minutes) as tt_amp80pct_2017,
percentile_disc(0.5) within group (order by travel_time_minutes) as tt_amp50pct_2017,
round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/
percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2) as lottr

from joined
where
--Mon-Fri
(extract(dow from measurement_tstamp )>0 and extract(dow from measurement_tstamp ) < 6) and
	--AM Peak
	(date_part('hour',measurement_tstamp) > 5 and date_part('hour',measurement_tstamp) < 10)
	group by tmc_code, geom)

update congestion_lottr
set lottr_amp_2017 = apl.lottr,
tt_amp50pct_2017 = apl.tt_amp50pct_2017,
tt_amp80pct_2017 = apl.tt_amp80pct_2017
from apl
where congestion_lottr.tmc_code = apl.tmc_code
