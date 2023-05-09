4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

** Note that this query keeps failing the test but during office hours you told me to just leave it. **

5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

** My accessibility metric simply subtracts the number of inacessible stops from the total stops of each neighborhood. However there were some complications with my code as you saw during office hours, where rows that are not accessible have been duplicated twice. I have tried numerous methods, however nothing seemed to work.**

6.  What are the _top five_ neighborhoods according to your accessibility metric?

**  My top five neighborhoods according to my accessibility metric is: Somerton, Bustleton, Overbrook, Oxford Circle, and Mayfair. **

7.  What are the _bottom five_ neighborhoods according to your accessibility metric?

** My bottom five neighborhoods according to my accessibility metric is: Crestmont Farms, Cedar Park, Woodland Terrace, Paschall, and Southwest Schuylkill **

8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

** I use a dataset from OpenDataPhilly and filtered it down to any record where the name is "UNIVERSITY OF PENNSYLVANIA" as my reference for Penn's campus. **
https://www.opendataphilly.org/dataset/philadelphia-universities-and-colleges


