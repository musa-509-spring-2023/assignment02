/* The "stop_desc" column shows the review of the closest cheesesteak store within
1 km of each rail stop. The cheesesteak review is gratefully provided by the Philadelphia
Cheesesteak adventure at https://www.facebook.com/ridesharejim/. The dataset was on the
persional website, but the domain has expired. It was updated until Nov 2021. The 
original dataset contains scores and review for each ingredient (meat, veg...) of the
cheesesteak. Enjoy!

*/

with 

septa_rail as (
    select 
        stop_name,
        stop_id,
        stop_lon,
        stop_lat,
        ST_MakePoint(stops.stop_lon, stops.stop_lat) as stop_geog
    from septa.rail_stops as stops  
),

septa_stops_cheese as (
select
        cheese.user_note as note,
        dist as distance,
        stops.stop_name as stop_name,
        stops.stop_id as stop_id,
        stops.stop_lon as stop_lon,
        stops.stop_lat as stop_lat
    from septa_rail as stops
    cross join lateral (
            select
                cheese.user_note,
                cheese.geog,
                cheese.geog::geography <-> stops.stop_geog::geography as dist
            from advanture.cheese as cheese
            order by dist
            limit 1
    ) cheese
)

select 
    stop_name,
    stop_id,
    stop_lon,
    stop_lat,
    case 
        when distance < 1000 then note
        else 'No cheesesteak store within 1 km'
    end as stop_desc
from septa_stops_cheese