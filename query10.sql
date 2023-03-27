/*
  You're tasked with giving more contextual information to rail stops
  to fill the stop_desc field in a GTFS feed. Using any of the data
  sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
  and PostgreSQL string functions, build a description (alias as stop_desc)
  for each stop. Feel free to supplement with other datasets (must provide
  link to data used so it's reproducible), and other methods of describing
  the relationships. SQL's CASE statements may be helpful for some operations.
*/

select stops.stop_id,
       stop_name,
       concat(
           'The passenger traffic at this station today is ',
            coalesce(passenger_count, 0),
            case when passenger_count > 0 then ' people' else ' person' end
       ) as stop_desc,
       stop_lon,
       stop_lat
from septa.rail_stops stops
left join (
    select stop_id, count(*) as passenger_count
    from septa.rail_stop_times stop_times
    join septa.rail_trips trips on stop_times.trip_id = trips.trip_id
    where pickup_type = 0 and drop_off_type = 0
    group by stop_id
) as counts on stops.stop_id = counts.stop_id;