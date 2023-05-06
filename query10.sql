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
