/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/
with

bus_shape_geog as (
    select
        shapes.shape_id,
        st_makeline(
    array_agg(
                st_setsrid(
                    st_makepoint(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326)
                order by shapes.shape_pt_sequence
            )
        )::geography as shape_geog
    from septa.bus_shapes as shapes
    group by shapes.shape_id
),

bus_shape_geog_length as (
    select
        bus_shape_geog.shape_id,
        bus_shape_geog.shape_geog,
        st_length(bus_shape_geog.shape_geog) as shape_length
    from bus_shape_geog
),

bus_shape_trips as (
    select
        routes.route_short_name,
        shape_id,
        bus_shape_geog_length.shape_length,
        bus_trips.trip_headsign,
        bus_shape_geog_length.shape_geog,
        route_id
    from bus_shape_geog_length
    inner join septa.bus_trips using (shape_id)
    inner join septa.bus_routes as routes using (route_id)
)

select distinct
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
from bus_shape_trips
order by shape_length desc
limit 2
