/*
5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

*/

/*To exam bus stop accessbility, I calculate density of wheelchair boarding in each neighborhood as the accessbility metric.
 I calculate the count of wheelchair boarding, and then divided it by area of each neighborhoods.
*/

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
        count(wheelchair_boarding) / area as dens
    from septa.bus_stops as stops
    inner join area
        on st_intersects(area.geog, stops.geog)
    where wheelchair_boarding = '1'
    group by name, wheelchair_boarding, area, area.geog
)

select *
from density
order by dens desc
