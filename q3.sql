SELECT 
	pwd.address,
	st.stop_name,
	st_distance(pwd.geog, st.geog) as distance
from phl.pwd_parcels as pwd
cross join lateral (
	select 
	sts.stop_name,
	sts.geog
	from septa.bus_stops as sts
	order by pwd.geog <-> sts.geog
) as st
order by distance DESC