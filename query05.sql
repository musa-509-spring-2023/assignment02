with

wc_stops as (
    select
        stops.stop_id,
        stops.stop_name,
        stops.geog,
        stops.wheelchair_boarding
    from septa.bus_stops as stops
    where stops.wheelchair_boarding = 1
),

nearest_wc as (
    select
        stops.stop_name as stop_name,
        stops.wheelchair_boarding,
        wc_stops.stop_name as wc_stop_name,
        wc_stops.dist as distance,
        stops.geog as stop_geog,
        wc_stops.geog as wc_stop_geog
    from septa.bus_stops as stops
    cross join lateral (
        select
            wc_stops.stop_name,
            wc_stops.geog,
            wc_stops.geog <-> stops.geog as dist -- noqa: PRS
        from wc_stops
        order by dist -- noqa
        limit 1
    ) as wc_stops
),

septa_bus_stop_neighborhoods as (
    select
        stops.stop_name,
        stops.wheelchair_boarding,
        stops.wc_stop_name,
        stops.distance,
        nh.name as neighborhood,
        nh.shape_area as area
    from nearest_wc as stops
    inner join azavea.neighborhoods as nh
        on
            st_within(
                st_setsrid(stops.stop_geog::geometry, 4326),
                st_setsrid(nh.geog::geometry, 4326)
            )
),

wc_metrics as (
    select
        neighborhood,
        count(case when wheelchair_boarding = 1 then 1 end) as count_wc,
        count(stop_name) as total_stops,
        count(case when wheelchair_boarding = 1 then 1 end)::float
        / count(stop_name)::float * 100 as pct,
        avg(distance) as avg_distance_from_wc,
        count(stop_name) / area * 10000000 as stop_density
    from septa_bus_stop_neighborhoods
    group by neighborhood, area
    order by stop_density desc
),

wc_metric as (
    select
        *,
        case
            when pct = 0 then 1
            when pct < 50 then 2
            when pct >= 50 and pct < 75 then 3
            when pct >= 75 and pct < 100 then 4
            when pct = 100 then 5
        end as pct_score,
        case
            when avg_distance_from_wc > 150 then 1
            when
                avg_distance_from_wc > 100
                and avg_distance_from_wc <= 150 then 2
            when
                avg_distance_from_wc > 50
                and avg_distance_from_wc <= 100 then 3
            when
                avg_distance_from_wc > 0
                and avg_distance_from_wc <= 50 then 4
            when avg_distance_from_wc = 0 then 5
        end as dist_score,
        case
            when stop_density < 10 then 1
            when stop_density >= 10 and stop_density < 25 then 2
            when stop_density >= 25 and stop_density < 50 then 3
            when stop_density >= 50 and stop_density < 65 then 4
            when stop_density >= 65 and stop_density < 90 then 5
        end as density_score
    from wc_metrics
)

select
    neighborhood as neighborhood_name,
    (pct_score + dist_score + density_score::float) / 3 as accessibility_metric,
    count_wc as num_bus_stops_accessible,
    total_stops - count_wc as num_bus_stops_inaccessible
from wc_metric
order by accessibility_metric desc;
