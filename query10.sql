SELECT
  stop_id,
  stop_name,
  CASE
    -- Check if rail stop is within University of Pennsylvania boundary
    WHEN ST_Within(ST_MakePoint(rs.stop_lon, rs.stop_lat), bu.geometry) THEN
      -- Get the nearest address to the rail stop
      CONCAT(
        ROUND(ST_Distance(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry))::integer,
        ' meters ',
        CASE
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 0 AND 90 THEN 'NE'
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 90 AND 180 THEN 'SE'
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 180 AND 270 THEN 'SW'
          ELSE 'NW'
        END,
        ' of ',
        pp."ADDRESS",
        ' in ',
        n.name,
        ', University of Pennsylvania'
      )
    ELSE
      -- Get the nearest address to the rail stop
      CONCAT(
        ROUND(ST_Distance(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry))::integer,
        ' meters ',
        CASE
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 0 AND 90 THEN 'NE'
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 90 AND 180 THEN 'SE'
          WHEN ST_Azimuth(ST_MakePoint(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 180 AND 270 THEN 'SW'
          ELSE 'NW'
        END,
        ' of ',
        pp."ADDRESS",
        ' in ',
        n.name
      )
  END AS stop_desc,
  rs.stop_lon,
  rs.stop_lat
FROM
  septa.rail_stops rs
  JOIN (
    SELECT
      p.geometry,
      p."ADDRESS",
      n.name,
      MIN(ST_Distance(ST_MakePoint(rs.stop_lon, rs.stop_lat), p.geometry)) AS distance
    FROM
      phl.pwd_parcels p
      CROSS JOIN azavea.neighborhoods n
      CROSS JOIN septa.rail_stops rs
    WHERE
      n.geometry && p.geometry
    GROUP BY
      p.geometry,
      p."ADDRESS",
      n.name
  ) AS ppn ON ST_DWithin(ST_MakePoint(rs.stop_lon, rs.stop_lat), ppn.geometry, ppn.distance)
  JOIN phl.pwd_parcels pp ON ppn.geometry = pp.geometry
  JOIN azavea.neighborhoods n ON ppn.name = n.name
  JOIN census.block_upenn_2020 bu ON ST_Intersects(ST_MakePoint(rs.stop_lon, rs.stop_lat), bu.geometry)
ORDER BY
  stop_id
