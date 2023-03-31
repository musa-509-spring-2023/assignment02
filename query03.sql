alter table phl.pwd_parcels
alter column geog type geography
using ST_Transform(geog::geometry, 4269);

alter table septa.bus_stops
alter column geog type geography
using ST_Transform(geog::geometry, 4269);

WITH 

filtered_parcels AS (
    SELECT 
	geog, 
	address as parcel_address
    FROM phl.pwd_parcels
    WHERE ST_Intersects(geog::geometry, ST_MakeEnvelope(-75.3, 39.9, -74.9, 40.2, 4269))
),

transformed_parcels AS (
    SELECT ST_Transform(geog::geometry, 4269) AS geog, parcel_address
    FROM filtered_parcels
),

indexed_parcels AS (
    SELECT parcel_address, geog
    FROM transformed_parcels
    ORDER BY geog <-> st_setsrid(st_makepoint(-75.2, 40.0), 4269)
    LIMIT 50000
),

closest_bus_stop AS (
    SELECT DISTINCT ON (indexed_parcels.parcel_address)
        indexed_parcels.parcel_address,
        bus_stops.stop_name,
        ST_Distance(indexed_parcels.geog, bus_stops.geog) AS distance
    FROM indexed_parcels
    CROSS JOIN LATERAL (
        SELECT stop_id, stop_name, geog
        FROM septa.bus_stops
        ORDER BY indexed_parcels.geog <-> geog LIMIT 1
    ) AS bus_stops
    ORDER BY indexed_parcels.parcel_address, distance
)

SELECT
    filtered_parcels.parcel_address,
    closest_bus_stop.stop_name,
    closest_bus_stop.distance
FROM filtered_parcels
JOIN closest_bus_stop ON filtered_parcels.parcel_address = closest_bus_stop.parcel_address
ORDER BY closest_bus_stop.distance DESC;

