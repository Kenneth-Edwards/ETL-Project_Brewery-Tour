-- select dist, airbnb_id, brewery from distance group by brewery, airbnb_id  order by dist;

create table rank_airbnb1 as
select airbnb_id, brewery, dist, rank() over w from
distance window w as (partition by brewery order by dist asc);

-- create a new table from the query below to only include the top 5 airbnb rankings for each brewery
create table rank_airbnb2 as
select airbnb_id, brewery, dist from rank_airbnb1 where rank < 6;

select * from rank_airbnb2;

-- NOT WORKING YET: attempting to join tables to get the airbnb NAME that matches the airbnb_id
select brewery dist rank_airbnb2.airbnb_id ny_abnb.airbnb_id airbnb_name 
from rank_airbnb2 
inner join ny_abnb on rank_airbnb2.airbnb_id = ny_abnb.airbnb_id;