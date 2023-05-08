/*
4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

    >_**HINT**: The `ST_MakeLine` function is useful here. You can see an example of how you could use it at [this MobilityData walkthrough](https://docs.mobilitydb.com/MobilityDB-workshop/master/ch04.html#:~:text=INSERT%20INTO%20shape_geoms) on using GTFS data. If you find other good examples, please share them in Slack._

    >_**HINT**: Use the query planner (`EXPLAIN`) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds._

    >_**HINT**: The `row_number` window function could also be useful here. You can read more about window functions [in the PostgreSQL documentation](https://www.postgresql.org/docs/9.1/tutorial-window.html). That documentation page uses the `rank` function, which is very similar to `row_number`. For more info about window functions you can check out:_
    >*   📑 [_An Easy Guide to Advanced SQL Window Functions_](https://towardsdatascience.com/a-guide-to-advanced-sql-window-functions-f63f2642cbf9) in Towards Data Science, by Julia Kho
    >*   🎥 [_SQL Window Functions for Data Scientists_](https://www.youtube.com/watch?v=e-EL-6Vnkbg) (and a [follow up](https://www.youtube.com/watch?v=W_NBnkLLh7M) with examples) on YouTube, by Emma Ding

    **Structure:**
    ```sql
    (
        route_short_name text,  -- The short name of the route
        trip_headsign text,  -- Headsign of the trip
        shape_geog geography,  -- The shape of the trip
        shape_length double precision  -- Length of the trip in meters
    )
    ```
*/

with 
makelinelength as(
	select 
	shape_id,
	ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence)) as shape_geog,
	ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence))::geography) as shape_length
	from septa.bus_shapes as shapes
	group by shape_id
),

mergetrip as(
	select *
	from makelinelength
	inner join septa.bus_trips as trips
		on trips.shape_id = makelinelength.shape_id
),

mergeroute as(
	select *
	from mergetrip
	inner join septa.bus_routes as routes
	on routes.route_id = mergetrip.route_id
)

select 
	route_short_name,
	trip_headsign,
	shape_geog,
	shape_length
from mergeroute
group by route_short_name,trip_headsign,shape_geog,shape_length
order by shape_length desc
limit 2  
