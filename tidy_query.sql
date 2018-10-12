select tmc_code,
date_part('year', measurement_tstamp) as year_record,
report_period,
case when(percentile_disc(0.5) within group (order by travel_time_minutes) = 0)
	then null
	else round(cast(percentile_disc(0.8) within group (order by travel_time_minutes)/percentile_disc(0.5) within group (order by travel_time_minutes) as numeric),2)
end as lottr
from inrix14to16data
group by tmc_code, year_record, report_period
order by tmc_code