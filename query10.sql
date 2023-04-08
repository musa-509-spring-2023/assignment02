-- ALTER TABLE septa.rail_stops
-- ADD geog geography(Point, 4326);

-- UPDATE septa.rail_stops
-- SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
-- CREATE INDEX IF NOT EXISTS rail_stops_geog_idx
--     ON septa.rail_stops USING gist
--     (geog)
--     TABLESPACE pg_default;
SELECT DISTINCT
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    COUNT(pp.parcelid) OVER (PARTITION BY stop_id) || ' parcels within 300-meter radius of the station' AS stop_desc
FROM septa.rail_stops AS sr
INNER JOIN phl.pwd_parcels AS pp
    ON ST_DWITHIN(pp.geog::geography, sr.geog::geography, 300);
