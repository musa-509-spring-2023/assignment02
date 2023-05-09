create index shape_index on septa.bus_shapes USING GiST(geom);

with shape_lengths as (
    select
        shape_id,
        ST_MakeLine(
            ST_Transform(geom2::geometry,3857)
            order by
                shape_pt_sequence asc
        ) as shape_geog,
		ST_Length(ST_MakeLine(
            ST_Transform(geom2::geometry,3857)
            order by
                shape_pt_sequence asc
        )) as shape_length
    from
        septa.bus_shapes
    group by
        shape_id
), trips_joined as (
select
	trips.trip_headsign as trip_headsign,
	sl.shape_length as shape_length,
	sl.shape_geog as shape_geog,
	trips.trip_id as trip_id,
	trips.route_id as route_id
from shape_lengths as sl
inner join septa.bus_trips as trips
on (sl.shape_id = trips.shape_id)
), final_table as(
select
	distinct routes.route_short_name as route_short_name,
	trips.trip_headsign as trip_headsign,
	trips.shape_geog as shape_geog,
	trips.shape_length as shape_length
from trips_joined as trips
inner join septa.bus_routes as routes
on (trips.route_id = routes.route_id)

)
select * from final_table order by shape_length desc limit 2;