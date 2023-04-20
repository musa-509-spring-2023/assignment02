SELECT
    septa.rail_stops.stop_id,
    septa.rail_stops.stop_name,
    rs.stop_lon,
    rs.stop_lat,
    CASE
        -- Check if rail stop is within University of Pennsylvania boundary
        WHEN ST_WITHIN(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), bu.geometry)
            THEN
            -- Get the nearest address to the rail stop
            CONCAT(
                ROUND(ST_DISTANCE(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry))::integer,
                ' meters ',
                CASE
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 0 AND 90 THEN 'NE'
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 90 AND 180 THEN 'SE'
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 180 AND 270 THEN 'SW'
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
                ROUND(ST_DISTANCE(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry))::integer,
                ' meters ',
                CASE
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 0 AND 90 THEN 'NE'
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 90 AND 180 THEN 'SE'
                    WHEN ST_AZIMUTH(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), pp.geometry) BETWEEN 180 AND 270 THEN 'SW'
                    ELSE 'NW'
                END,
                ' of ',
                pp."ADDRESS",
                ' in ',
                n.name
            )
    END AS stop_desc
FROM
    septa.rail_stops AS rs
INNER JOIN (
    SELECT
        p.geometry,
        p."ADDRESS",
        n.name,
        MIN(ST_DISTANCE(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), p.geometry)) AS distance
    FROM
        phl.pwd_parcels AS p
    CROSS JOIN azavea.neighborhoods AS n
    CROSS JOIN septa.rail_stops AS rs
    WHERE
        n.geometry && p.geometry
    GROUP BY
        p.geometry,
        p."ADDRESS",
        n.name
    ) AS ppn ON ST_DWITHIN(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), ppn.geometry, ppn.distance)
INNER JOIN phl.pwd_parcels AS pp ON ppn.geometry = pp.geometry
INNER JOIN azavea.neighborhoods AS n ON ppn.name = n.name
INNER JOIN census.block_upenn_2020 AS bu ON ST_INTERSECTS(ST_MAKEPOINT(rs.stop_lon, rs.stop_lat), bu.geometry)
ORDER BY
    septa.rail_stops.stop_id
