drop table if exists npmrds_2018_truck_seconds_nonull_10min;
create table npmrds_2018_truck_seconds_nonull_10min (
tmc_code varchar(50),
measurement_tstamp timestamp,
speed numeric,
average_speed numeric,
reference_speed numeric,
travel_time_seconds numeric,
data_density varchar(9)
);

\copy npmrds_2018_truck_seconds_nonull_10min from program 'unzip -p /home/fullerm/repos/npmrds/downloads/2018/truck/npmrds_2018_truck_seconds_nonull_10min.zip npmrds_2018_truck_seconds_nonull_10min.csv' with (format csv, header);

\echo 'Creating 2018 AM Peak table at ' `date`
create table npmrds_truck_amp_2018 as 
    select * from npmrds_2018_truck_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 6 and 9);

\echo 'Creating 2018 Midday Peak table at ' `date`
create table npmrds_truck_midd_2018 as
    select * from npmrds_2018_truck_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--midday Peak
	(date_part('hour',measurement_tstamp) between 10 and 15);

\echo 'Creating 2018 PM Peak table at ' `date`
create table npmrds_truck_pmp_2018 as
    select * from npmrds_2018_truck_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--PM Peak 4-8
	(date_part('hour',measurement_tstamp) between 16 and 19);

\echo 'Creating 2018 Overnight table at ' `date`
create table npmrds_truck_ovn_2018 as
    select * from npmrds_2018_truck_seconds_nonull_10min
    where
    --overnight is 8 PM to 6 AM every day of the week
    (date_part('hour', measurement_tstamp)  < 6 or date_part('hour', measurement_tstamp)  > 19 );

\echo 'Creating 2018 Weekend Peak table at ' `date`
create table npmrds_truck_we_2018 as
    select * from npmrds_2018_truck_seconds_nonull_10min
    where
    --Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19) and
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6);

\echo 'import complete at ' `date`