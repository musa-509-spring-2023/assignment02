/*

What are the bottom five neighborhoods according to your accessibility metric?

*/


-- create table for base info
with trips_count as (
    select
        stop_id,
        count(*) as trip_count,
		direction_id,
		trips.route_id as route_id
    from septa.stop_times as stop_times
	left join (SELECT route_id, trip_id, direction_id FROM septa.bus_trips) as trips
		on trips.trip_id = stop_times.trip_id
    group by stop_id, direction_id, route_id 
    order by stop_id asc, direction_id
),

-- get the stop_id, trip_count, and whether the trip_count is more frequent than 50% of the trips
-- some stops have multiple routes that are in the frequent and not-frequent category. I average these multiple routes.
stops_frequency as (
select
	stop_id,
    round(avg(CASE WHEN trip_count > (select percentile_disc(0.50) within group (order by trips_count.trip_count) from trips_count) THEN 1 ELSE 0
	END),2 ) AS frequent_or_not
from trips_count
group by stop_id
order by stop_id
), 

stops as (
select
	stops.stop_id as stop_id,
	stops.wheelchair_boarding as wc_board,
	stops.geog::geometry as geog,
	nhoods.mapname as neighborhood_name,
	st_freq.frequent_or_not as frequent_or_not
from septa.bus_stops as stops
left join azavea.neighborhoods as nhoods
	on st_contains(nhoods.geog::geometry, stops.geog::geometry)
left join stops_frequency as st_freq
	on st_freq.stop_id = stops.stop_id
),

-- create score
-- if a stop has no wheelchair boarding, it's a 0
--- if a stop has wheelchair boarding, then the average route frequency is given.
stops_score as (
    select
        stop_id,
        neighborhood_name,
        wc_board,
        frequent_or_not,
	CASE
		WHEN wc_board != 1 THEN 0
		WHEN wc_board = 1 THEN frequent_or_not
		ELSE 0
	END as accessibility_metric
    from stops
)

-- get the average score for each neighborhood, the neighborhood name, the number of stops above 0.5 score, the number of stops below 0.5 score
select
    neighborhood_name,
    round(avg(accessibility_metric),2) as accessibility_metric,
    count(CASE WHEN accessibility_metric > 0.5 THEN 1 END) as num_bus_stops_accessible,
    count(CASE WHEN accessibility_metric < 0.5 THEN 1 END) as num_bus_stops_inaccessible
from stops_score
group by neighborhood_name
order by accessibility_metric asc, num_bus_stops_inaccessible desc, neighborhood_name 
limit 5
