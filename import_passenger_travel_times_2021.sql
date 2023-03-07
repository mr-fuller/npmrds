drop table if exists lmw_2021_inrix_passenger_seconds_nonull_10min;
create table lmw_2021_inrix_passenger_seconds_nonull_10min (
tmc_code varchar(50),
measurement_tstamp timestamp,
speed numeric,
average_speed numeric,
reference_speed numeric,
travel_time_seconds numeric,
data_density varchar(9)
);

\copy lmw_2021_inrix_passenger_seconds_nonull_10min from program 'unzip -p /home/fullerm/repos/npmrds/downloads/2021/passenger/lmw_2021_inrix_passenger_seconds_nonull_10min.zip lmw_2021_inrix_passenger_seconds_nonull_10min.csv' with (format csv, header);


\echo 'Creating 2021 AM Peak table at ' `date`
create table npmrds_passenger_amp_2021 as 
    select * from npmrds_2021_passenger_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--AM Peak
	(date_part('hour',measurement_tstamp) between 6 and 9);
\echo 'Creating 2021 Midday Peak table at ' `date`
create table npmrds_passenger_midd_2021 as
    select * from npmrds_2021_passenger_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--midday Peak
	(date_part('hour',measurement_tstamp) between 10 and 15);

\echo 'Creating 2021 PM Peak table at ' `date`
create table npmrds_passenger_pmp_2021 as
    select * from npmrds_2021_passenger_seconds_nonull_10min
    where
    --Mon-Fri
    (extract(dow from measurement_tstamp ) between 1 and 5) and
	--PM Peak 4-8
	(date_part('hour',measurement_tstamp) between 16 and 19);

\echo 'Creating 2021 Weekend Peak table at ' `date`
create table npmrds_passenger_we_2021 as
    select * from npmrds_2021_passenger_seconds_nonull_10min
    where
    --Sat and Sun 6AM-8PM
	(date_part('hour', measurement_tstamp) between 6 and 19) and
	(extract(dow from measurement_tstamp) = 0 or extract(dow from measurement_tstamp) = 6);
