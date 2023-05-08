with
area as (
    select
        nb.geog as geog,
        name,
        st_area(nb.geog) as area
    from azavea.neighborhoods as nb
),

density as (
    select
        name,
        area.geog,
        sum(wheelchair_boarding) / area as dens,
        sum(wheelchair_boarding) as num_bus_stops_accessible
    from septa.bus_stops as stops
    inner join area
        on st_intersects(area.geog, stops.geog)
    where wheelchair_boarding = '1'
    group by name, wheelchair_boarding, area, area.geog
),

allwheelchair as (
    select
        nb.name as name,
        nb.geog,
        sum(wheelchair_boarding) as num_bus_stops_assall
    from septa.bus_stops as stops
    inner join azavea.neighborhoods as nb
        on st_intersects(nb.geog, stops.geog)
    group by nb.name, nb.geog
)

select
    density.name as neighborhood_name,
    dens as accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_assall - num_bus_stops_accessible as num_bus_stops_inaccessible
from density
inner join allwheelchair
    on allwheelchair.name = density.name
order by dens asc
limit 5
