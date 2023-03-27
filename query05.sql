/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.
  Use Azavea's neighborhood dataset from OpenDataPhilly along with an
  appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation
  for help. Use some creativity in the metric you devise in rating neighborhoods.
*/

with neighborhood_stops as (
    select
        n.name,
        n.geometry,
        n.shape_area,
        stops.wheelchair_boarding,
        stops.stop_lon,
        stops.stop_lat,
        st_x(st_centroid(n.geometry)) as neighborhood_center_lon,
        st_y(st_centroid(n.geometry)) as neighborhood_center_lat
    from azavea.neighborhoods as n
    inner join septa.bus_stops as stops on st_contains(n.geometry, stops.geog::geometry)
),

neighborhood_stops_count as (
    select
        name,
        count(*) as total_stops,
        sum(case when wheelchair_boarding = 1 then 1 else 0 end) as accessible_stops
    from neighborhood_stops
    group by name
),

neighborhood_stops_weight as (
    select
        nsc.name,
        ns.wheelchair_boarding,
        nsc.total_stops,
        nsc.accessible_stops,
        (1 / (1 + st_distance(st_centroid(ns.geometry), st_setsrid(st_makepoint(ns.stop_lon, ns.stop_lat), 4326)) * 0.000621371 * 2)) as weight
    from neighborhood_stops_count as nsc
    inner join neighborhood_stops as ns on nsc.name = ns.name
),

neighborhood_accessibility as (
    select
        ns.name,
        sum(nsw.weight * (nsw.accessible_stops / nsw.total_stops)) as accessibility_score
    from neighborhood_stops_weight as nsw
    inner join neighborhood_stops as ns on nsw.name = ns.name
    group by ns.name, ns.shape_area
)

select
    n.name as neighborhood_name,
    na.accessibility_score
from neighborhood_accessibility as na
inner join azavea.neighborhoods as n on na.name = n.name
order by na.accessibility_score desc;
