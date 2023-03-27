/*
  What are the bottom five neighborhoods according to your accessibility metric
*/

with neighborhood_stops as (
    select n.name,
           n.geometry,
           n.shape_area,
           stops.wheelchair_boarding,
           stops.stop_lon,
           stops.stop_lat
    from azavea.neighborhoods n
    join septa.bus_stops stops ON st_contains(n.geometry, stops.geog::geometry)
),
neighborhood_stops_count AS (
    select name,
           count(*) as total_stops,
           sum(case when wheelchair_boarding = 1 then 1 else 0 end) as num_bus_stops_accessible,
           (count(*) - sum(case when wheelchair_boarding = 1 then 1 else 0 end)) as num_bus_stops_inaccessible
    from neighborhood_stops
    group by name
),
neighborhood_stops_weight AS (
    select nsc.name,
           ns.wheelchair_boarding,
           nsc.total_stops,
           nsc.num_bus_stops_accessible,
           nsc.num_bus_stops_inaccessible,
           (1 / (1 + st_distance(st_centroid(ns.geometry), st_setsrid(st_makepoint(stop_lon, stop_lat), 4326)) * 0.000621371 * 2)) AS weight
    from neighborhood_stops_count nsc
    join neighborhood_stops ns ON nsc.name = ns.name
),
neighborhood_accessibility as (
    select ns.name,
           sum(weight * (num_bus_stops_accessible / total_stops))  as accessibility_metric,
           num_bus_stops_accessible,
           num_bus_stops_inaccessible
    from neighborhood_stops_weight nsw
    join neighborhood_stops ns on nsw.name = ns.name
    group by ns.name, num_bus_stops_accessible, num_bus_stops_inaccessible
)
select n.name as neighborhood_name,
       accessibility_metric,
       num_bus_stops_accessible,
       num_bus_stops_inaccessible
from neighborhood_accessibility na
join azavea.neighborhoods n on na.name = n.name
order by na.accessibility_metric, na.num_bus_stops_accessible
limit 5;

