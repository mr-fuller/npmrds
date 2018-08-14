# NPMRDS
Wrangling some vehicle probe data from the National Performance Management Research Data Set (NPMRDS) in PostGIS. Yeehaw?

# How to use
Run all the DWDH queries in a single step from the command line by typing 'psql -U <user> -d <dbname> -f "<updated/file/path/location>/all_queries.sql" and enter your password if prompted.
  
# Trucks
Files in the trucks folder are used for calculating Truck Travel Time Reliability (TTTR), which is slightly different from LOTTR in that it uses the 95th percentile speed instead of the 80th percentile speed.
This folder also contains file that enables you to run all the queries in a batch - all_tttr_queries.sql.


- join_easy_button_report.sql: this query joins the "easy button" report output to a geometry layer for the purpose of visualizing the data in the program of your choosing (R, QGIS, ArcGIS, etc).

This repository will be limited to new or custom analyses or measures developed for TMACOG planning purposes. Any resemblance to proprietary code or NPMRDS products is purely coincidental. If you suspect the code attempts to knock-off or reverse engineer NPMRDS products in any way, please do not hesitate to contact me.
