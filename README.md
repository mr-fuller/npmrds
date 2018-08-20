# NPMRDS
Wrangling some vehicle probe data from the National Performance Management Research Data Set (NPMRDS) in PostgreSQL/PostGIS. Yeehaw?

## General usage notes
Each category of performance metric comes with queries for distinct years and periods, but also with a file that allows the queries to be run in a batch, usually named something like "all_metric_queries.sql". If you are using the command line, you can run the batch with the command: `psql -U *user* -d *dbname* -f "<updated/file/path/location>/all_<metric>_queries.sql"` and enter your password if prompted.

### Other useful files
- join_easy_button_report.sql: If you are familiar with the NPMRDS Ritis site reports, this query joins the "easy button" report output to a geometry layer for the purpose of visualizing the data in the program of your choosing (R, QGIS, etc).


## Passengers
Files in the *passengers* folder are used for calculating Level of Travel Time Reliability (LOTTR) using the median and 80th percentile speeds from vehicle probe data, which should only be from passenger vehicles.
- batch file: all_lottr_queries.sql

## Trucks
Files in the *trucks* folder are used for calculating Truck Travel Time Reliability (TTTR), which is slightly different from LOTTR in that it uses the 95th percentile speed instead of the 80th percentile speed, and should be used only with data from trucks. They are currently set up assuming you have 2017 data and 2012-2016 data in separate tables.
- batch file: all_tttr_queries.sql 

## Distance Weighted Delay Hours (DWDH)
Files in the *dwdh* folder can be used to calculate a metric borrowed from Indiana Department of Transportation (INDOT) Mobility reports, although it is not a required performance metric. This approach counts hours where roadway speeds were less than 75% of posted or free flow speeds.
- batch file: all_dwdh_queries.sql




This repository will be limited to new or custom analyses or measures developed for TMACOG planning purposes. Any resemblance to proprietary code or NPMRDS products is purely coincidental. If you suspect the code attempts to knock-off or reverse engineer NPMRDS products in any way, please do not hesitate to contact me.
