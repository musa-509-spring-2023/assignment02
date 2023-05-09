WITH 

trips AS (
    SELECT
        route_id,
        trip_headsign,
        shape_id
    FROM septa.bus_trips
),

shapes AS (
    SELECT
        shape_id,
        ST_MakeLine(
            ST_MakePoint(shape_pt_lon, shape_pt_lat)
            ORDER BY shape_pt_sequence
        ) AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

routes AS (
    SELECT
        trips.route_id,
        routes.route_short_name,
        trips.trip_headsign,
        shapes.shape_geog,
        ST_Length(shapes.shape_geog::geometry) AS shape_length
    FROM trips
    JOIN septa.bus_routes routes ON trips.route_id = routes.route_id
    JOIN shapes ON trips.shape_id = shapes.shape_id
),

longest_routes AS (
    SELECT
        route_short_name,
        trip_headsign,
        shape_geog,
        shape_length,
        ROW_NUMBER() OVER (ORDER BY shape_length DESC) AS row_num
    FROM routes
)

SELECT
    route_short_name,
    trip_headsign,
    shape_length,
	shape_geog
FROM longest_routes
WHERE row_num <= 2;
