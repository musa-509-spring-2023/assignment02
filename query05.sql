/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.
  Use Azavea's neighborhood dataset from OpenDataPhilly along with an
  appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation
  for help. Use some creativity in the metric you devise in rating neighborhoods.
*/

with neighborhood_stops as (
    select n.name,
           n.geometry,
           n.shape_area,
           stops.wheelchair_boarding,
           st_x(st_centroid(n.geometry)) as neighborhood_center_lon,
           st_y(st_centroid(n.geometry)) as neighborhood_center_lat,
           stops.stop_lon,
           stops.stop_lat
    from azavea.neighborhoods n
    join septa.bus_stops stops ON st_contains(n.geometry, stops.geog::geometry)
),
neighborhood_stops_count AS (
    select name,
           count(*) AS total_stops,
           sum(case when wheelchair_boarding = 1 then 1 else 0 end) as accessible_stops
    FROM neighborhood_stops
    GROUP BY name
),
neighborhood_stops_weight AS (
    select nsc.name,
           wheelchair_boarding,
           total_stops,
           accessible_stops,
           (1 / (1 + ST_Distance(st_centroid(ns.geometry), ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)) * 0.000621371 * 2)) AS weight
    from neighborhood_stops_count nsc
    join neighborhood_stops ns ON nsc.name = ns.name
),
neighborhood_accessibility as (
    select ns.name,
           sum(weight * (accessible_stops / total_stops))  as accessibility_score
    FROM neighborhood_stops_weight nsw
    join neighborhood_stops ns ON nsw.name = ns.name
    group by ns.name, ns.shape_area
)
select n.name as neighborhood_name, na.accessibility_score
from neighborhood_accessibility na
join azavea.neighborhoods n ON na.name = n.name
order by na.accessibility_score desc;
