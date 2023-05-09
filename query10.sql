SELECT
  s.stop_id,
  s.stop_name,
  CONCAT(
    ROUND(ST_Distance(p.geog::geometry, s.geog::geometry))::text,
    ' meters ',
    CASE
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 22.5 AND 67.5 THEN 'NE'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 67.5 AND 112.5 THEN 'E'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 112.5 AND 157.5 THEN 'SE'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 157.5 AND 202.5 THEN 'S'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 202.5 AND 247.5 THEN 'SW'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 247.5 AND 292.5 THEN 'W'
      WHEN ST_Azimuth(p.geog::geometry, s.geog::geometry) BETWEEN 292.5 AND 337.5 THEN 'NW'
      ELSE 'N'
    END,
    ' of ',
    p.num_accoun
  ) AS stop_desc,
  s.stop_lon,
  s.stop_lat
FROM
  SEPTA.bus_stops s
  CROSS JOIN LATERAL (
    SELECT
      ST_Centroid(p.geog) AS geog,
      p.num_accoun
    FROM
      phl.pwd_parcels p
    ORDER BY
      s.geog <-> p.geog
    LIMIT 1
  ) p;
