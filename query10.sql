select 
	rails.stop_id as stop_id,
	rails.stop_name,
	pwd.BLDG_DESC as stop_desc,
	rails.stop_lat,
	rails.stop_lon
from septa.rail_stops as rails
join phl.pwd_parcels as pwd on st_intersects(pwd.geom,  st_SetSRID(st_makepoint(rails.stop_lon,rails.stop_lat),4326))