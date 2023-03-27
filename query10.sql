/*
  You're tasked with giving more contextual information to rail stops
  to fill the stop_desc field in a GTFS feed. Using any of the data
  sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
  and PostgreSQL string functions, build a description (alias as stop_desc)
  for each stop. Feel free to supplement with other datasets (must provide
  link to data used so it's reproducible), and other methods of describing
  the relationships. SQL's CASE statements may be helpful for some operations.
*/

with counts as (
    select
        stop_times.stop_id,
        count(*) as passenger_count
    from septa.rail_stop_times as stop_times
    inner join septa.rail_trips as trips on stop_times.trip_id = trips.trip_id
    where stop_times.pickup_type = 0 and stop_times.drop_off_type = 0
    group by stop_times.stop_id
)

select
    stops.stop_id,
    stops.stop_name,
    stops.stop_lon,
    stops.stop_lat,
    concat(
        'The passenger traffic at this station today is ',
        coalesce(counts.passenger_count, 0),
        case when counts.passenger_count > 0 then ' people' else ' person' end
    ) as stop_desc
from septa.rail_stops as stops
left join counts on stops.stop_id = counts.stop_id;
