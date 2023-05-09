with

bus_shapes as (
    select
        shape_id,
        ST_MAKELINE(
            ARRAY_AGG(
                ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326)
                order by shape_pt_sequence
        ) -- noqa: L003
        ) as shape_geog
    from septa.bus_shapes
    group by shape_id
),

bus_shape_length as (
    select
        shape_id,
        shape_geog,
        ST_LENGTH(shape_geog::geography) as shape_length
    from bus_shapes
    group by shape_id, shape_geog
),

bus_trips as (
    select
        septa.bus_trips.trip_headsign,
        septa.bus_trips.route_id,
        bus_shape_length.shape_id as shape_id,
        bus_shape_length.shape_geog as shape_geog,
        bus_shape_length.shape_length as shape_length
    from septa.bus_trips
    inner join bus_shape_length
        on septa.bus_trips.shape_id = bus_shape_length.shape_id
)

select distinct
    route_short_name, -- noqa: L027
    bus_trips.trip_headsign as trip_headsign,
    bus_trips.shape_geog as shape_geog,
    bus_trips.shape_length as shape_length
from septa.bus_routes
inner join bus_trips
    on bus_routes.route_id = bus_trips.route_id
order by bus_trips.shape_length desc
limit 2;
