with

wheelchair_stop as (
    select
        wheelchair_boarding,
        stop_name,
        geog,
        case wheelchair_boarding
            when 1 then 'YES'
            when 2 then 'NO'
        end as wheelchair
    from septa.bus_stops
),

neighorhoods_area as (
    select
        geog,
        listname as neighborhood_name,
        shape_area / 1000000 as area_km
    from azavea.neighborhoods
),

neig_wheel_count as (
    select
        neighorhoods_area.neighborhood_name,
        neighorhoods_area.area_km,
        count(
            case wheelchair_stop.wheelchair when 'YES' then 1 end
        ) as with_wheelchair,
        count(
            case wheelchair_stop.wheelchair when 'NO' then 1 end
        ) as no_wheelchair
    from wheelchair_stop
    inner join neighorhoods_area
        on st_intersects(wheelchair_stop.geog, neighorhoods_area.geog)
    group by neighorhoods_area.neighborhood_name, neighorhoods_area.area_km
)

select
    neighborhood_name,
    with_wheelchair as num_bus_stops_accessible,
    no_wheelchair as num_bus_stops_inaccessible,
    with_wheelchair / area_km as accessibility_metric
from neig_wheel_count
order by accessibility_metric
limit 5
