drop table if exists lmw_2019_inrix_truck_seconds_nonull_10min;
create table lmw_2019_inrix_truck_seconds_nonull_10min (
tmc_code varchar(50),
measurement_tstamp timestamp,
speed numeric,
average_speed numeric,
reference_speed numeric,
travel_time_seconds numeric,
data_density varchar(9)
);

\copy lmw_2019_inrix_truck_seconds_nonull_10min from program 'unzip -p /home/fullerm/repos/npmrds/downloads/2019/truck/lmw_2019_inrix_truck_seconds_nonull_10min.zip lmw_2019_inrix_truck_seconds_nonull_10min.csv' with (format csv, header);

