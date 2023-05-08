/*

    Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

    NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

*/

-- create table for base info
with stops as (
    select
        stops.stop_id as stop_id,
        stops.wheelchair_boarding as wc_board,
        stops.geog::geometry as geog,
        nhoods.mapname as neighborhood_name
    from septa.bus_stops as stops
    left join azavea.neighborhoods as nhoods
        on st_contains(nhoods.geog::geometry, stops.geog::geometry)
),

-- create score and summarize numbers
nhoods_inally as (
    select
        neighborhood_name,
        count(*)::double precision as stops_inally
    from stops
    where wc_board != 1
    group by neighborhood_name
),

nhoods_total as (
    select
        neighborhood_name,
        count(*)::double precision as stops_total
    from stops
    group by neighborhood_name
)

select
    nhoods_total.neighborhood_name as neighborhood_name,
    nhoods_total.stops_total::integer as num_bus_stops_accessible,
    coalesce(nhoods_inally.stops_inally, 0)::integer as num_bus_stops_inaccessible,
    (nhoods_total.stops_total - coalesce(nhoods_inally.stops_inally, 0)) / nhoods_total.stops_total as accessibility_metric
from nhoods_total
left join nhoods_inally
    on nhoods_total.neighborhood_name = nhoods_inally.neighborhood_name
