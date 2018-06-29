drop table if exists pm3_2017_report_geom;
create table pm3_2017_report_geom as(
select a.tmc,
a.tmctype,
a.roadnumber,a.roadname,a.isprimary,a.firstname,a.tmclinear,a.county, a.zip,
a.thrulanes,a.route_numb,a.route_sign,a.aadt,a.aadt_singl,a.aadt_combi,a.nhs_pct,
a.geom,
b.*
from tmacog_tmcs a
join pm3_2017_report b
on a.tmc = b.travel_time_code);
select * from tmacog_tmcs;
