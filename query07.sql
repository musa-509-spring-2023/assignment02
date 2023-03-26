/*


What are the bottom five neighborhoods according to your accessibility metric?

Both #6 and #7 should have the structure:

(
  neighborhood_name text,  -- The name of the neighborhood
  accessibility_metric ...,  -- Your accessibility metric value
  num_bus_stops_accessible integer,
  num_bus_stops_inaccessible integer
)


*/

with
pop as(
select b.total, a.geog
from census.blockgroups_2020 as a 
	inner join census.population_2020 as b
	on '1500000US' || a.geoid = b.geoid),

n1 as(
select c.name, sum(pop.total) * 1.0 /c.shape_area as pop_density, c.geog
from azavea.neighborhoods as c
	left join pop
	on st_intersects(c.geog, pop.geog)
group by c.name, c.shape_area , c.geog),

s as(
	select s.geog,
	case when wheelchair_boarding = 1 then 1
	when wheelchair_boarding = 2 then 0
	else 0 end as wheelchair_boarding
	from septa.bus_stops s
)

select n1.name as neighborhood_name, 
        Round((1/ n1.pop_density)* sum(s.wheelchair_boarding)/count(s.wheelchair_boarding),2) as accessibility_metric, 
        sum(s.wheelchair_boarding) as num_bus_stops_accessible,
        count(s.wheelchair_boarding) as num_bus_stops_inaccessible
	from n1
	left join s
	on st_within(s.geog::geometry, n1.geog::geometry)
	group by n1.name, n1.pop_density 
    order by  accessibility_metric asc
    limit 5

