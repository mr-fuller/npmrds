--This query will return the average travel time in minutes each month for a TMC segment in the NPMRDS dataset

select distinct date_part('month', measurement_tstamp) as month, 
tmc_code,
count(travel_time_seconds),
--we use the harmonic mean here:
0.403456190300/((sum(1/speed)/count(speed))^(-1)/60) as average_travel_time_minutes --0.4 is the length of the segment

from npmrds2017data 
where tmc_code = '108-04620' 
group by month;
