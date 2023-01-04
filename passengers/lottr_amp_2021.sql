--drop table congestion_lottr;
--create table congestion_lottr;

alter table congestion_lottr
add column if not exists lottr_amp_2021 numeric,
add column if not exists tt_amp50pct_2021 numeric,
add column if not exists tt_amp80pct_2021 numeric;

with
joined as(

select i.*,
g.*
from npmrds_2021_passenger_seconds_nonull_10min as i
full join tmacog_tmcs as g
on g.tmc = i.tmc_code
),


apl as (
select
geom,
--year_record,
	case when (state = 'Ohio')
	then '39'
	else '26'
	end as state_code,
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

percentile_cont(0.8) within group (order by travel_time_seconds) as tt_amp80pct,
percentile_cont(0.5) within group (order by travel_time_seconds) as tt_amp50pct,
round(cast(percentile_cont(0.8) within group (order by travel_time_seconds)/
percentile_cont(0.5) within group (order by travel_time_seconds) as numeric),2) as lottr

from joined
where
--Mon-Fri
(extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 6 and 9)
	group by tmc_code, geom, joined.state, joined.f_system,joined.urban_code,joined.faciltype, joined.nhs, joined.aadt, joined.miles, joined.direction)

update congestion_lottr
set lottr_amp_2021 = apl.lottr,
tt_amp50pct_2021 = apl.tt_amp50pct,
tt_amp80pct_2021 = apl.tt_amp80pct
from apl
where congestion_lottr.tmc_code = apl.travel_time_code
