select
    sbt.route_id as route_short_name,
    sbt.trip_headsign as trip_headsign,
    ST_LENGTH(ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence))) as shape_length,
    ST_MAKELINE(ARRAY_AGG(ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence)) as shape_geog

from septa.bus_trips as sbt
inner join septa.bus_shapes as sbs
    on sbt.shape_id = sbs.shape_id
group by route_short_name, trip_headsign
order by shape_length desc
limit 2
