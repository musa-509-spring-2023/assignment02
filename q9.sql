with pwd as (select gross_area as sa from phl.pwd_parcels
                                          where address like '%220-30 S 34TH ST%')
select geoid
from census.blockgroups_2020 as cen
inner join pwd
    on cen.aland >= pwd.sa
where cen.countyfp = '101' and namelsad = 'Block Group 2' and (intptlon::float::text like '-75.1954136')
