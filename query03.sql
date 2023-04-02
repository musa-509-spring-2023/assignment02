/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

    Your query should run in under two minutes.
*/

-- get the centoird of all the parcels

SELECT
    stops.stop_name AS stop_name,
    parcels.address AS parcel_address,
    st_distance(stops.geog, parcels.geog) AS distance
FROM phl.pwd_parcels AS parcels
CROSS JOIN LATERAL (
    SELECT
        stops.stop_name,
        stops.geog
    FROM septa.bus_stops AS stops
    ORDER BY stops.geog <-> parcels.geog
    LIMIT 1
) AS stops
ORDER BY distance DESC;
