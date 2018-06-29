drop table if exists pm3_2017_report_geom;
create table pm3_2017_report_geom as(
select a.tmc,
a.geom,
b.*
from tmacog_tmcs a
join pm3_2017_report b
on a.tmc = b.travel_time_code);

