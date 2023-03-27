/*
  What are the bottom five neighborhoods according to your accessibility metric
*/

with neighborhood_stops as (
    select
        n.name,
        n.geometry,
        n.shape_area,
        stops.wheelchair_boarding,
        stops.stop_lon,
        stops.stop_lat
    from azavea.neighborhoods as n
    inner join septa.bus_stops as stops on st_contains(n.geometry, stops.geog::geometry)
),

neighborhood_stops_count as (
    select
        name,
        count(*) as total_stops,
        sum(case when wheelchair_boarding = 1 then 1 else 0 end) as num_bus_stops_accessible,
        (count(*) - sum(case when wheelchair_boarding = 1 then 1 else 0 end)) as num_bus_stops_inaccessible
    from neighborhood_stops
    group by name
),

neighborhood_stops_weight as (
    select
        nsc.name,
        ns.wheelchair_boarding,
        nsc.total_stops,
        nsc.num_bus_stops_accessible,
        nsc.num_bus_stops_inaccessible,
        (1 / (1 + st_distance(st_centroid(ns.geometry), st_setsrid(st_makepoint(ns.stop_lon, ns.stop_lat), 4326)) * 0.000621371 * 2)) as weight
    from neighborhood_stops_count as nsc
    inner join neighborhood_stops as ns on nsc.name = ns.name
),

neighborhood_accessibility as (
    select
        ns.name,
        nsw.num_bus_stops_accessible,
        nsw.num_bus_stops_inaccessible,
        sum(nsw.weight * (nsw.num_bus_stops_accessible / nsw.total_stops)) as accessibility_metric
    from neighborhood_stops_weight as nsw
    inner join neighborhood_stops as ns on nsw.name = ns.name
    group by ns.name, nsw.num_bus_stops_accessible, nsw.num_bus_stops_inaccessible
)

select
    n.name as neighborhood_name,
    na.accessibility_metric,
    na.num_bus_stops_accessible,
    na.num_bus_stops_inaccessible
from neighborhood_accessibility as na
inner join azavea.neighborhoods as n on na.name = n.name
order by na.accessibility_metric, na.num_bus_stops_accessible
limit 5;
