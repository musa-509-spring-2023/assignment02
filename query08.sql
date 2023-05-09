/*
With a query, find out how many census block groups 
Penn's main campus fully contains. Discuss which dataset 
you chose for defining Penn's campus.
*/

SELECT COUNT(*)
FROM census.blockgroups_2020 AS b
WHERE ST_INTERSECTS(
    ST_GEOMFROMTEXT('POLYGON((-75.18927722389427 39.955400791342754,  
								-75.20170473650438 39.95679597872243, 
								-75.19851818096173 39.94802656127726, 
								-75.19840419155959 39.94804724221181, 
								-75.19069545818961 39.948279029228914,
				   				-75.18927722389427 39.955400791342754))'
						, '4326'),
    ST_SETSRID(b.geog::geography, '4326')
);
	

/* 
ANSWER: 13
Discussion: First, I traced a polygon around the appropriate streets, approximately from Market
Street to Curie Boulevard.  Then, I used ST_INTERSECTS to find the Census blockgroups (from the Census
dataset) to count the number of instances occur within the given polygon boundary.
*/	