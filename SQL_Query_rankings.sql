create table rank_airbnb1 as
select airbnb_id, brewery, dist, rank() over w from
distance window w as (partition by brewery order by dist asc);

--  create a new table from the query below to only include the top 5 airbnb rankings for each brewery
create table rank_airbnb2 as
select airbnb_id, brewery, dist, rank from rank_airbnb1 where rank < 6;

select * from rank_airbnb2;

--  join tables to get the airbnb NAME that matches the airbnb_id
create table airbnb_rank1 as
select rank_airbnb2.brewery, rank_airbnb2.airbnb_id, 
ny_abnb.airbnb_name, rank_airbnb2.rank, ny_abnb.price, 
rank_airbnb2.dist, (rank_airbnb2.dist * 5280) as feet_dist
from rank_airbnb2 
inner join ny_abnb on rank_airbnb2.airbnb_id = ny_abnb.airbnb_id
where rank_airbnb2.rank = 1
group by brewery, rank_airbnb2.dist, rank_airbnb2.rank, rank_airbnb2.airbnb_id, 
ny_abnb.airbnb_id, ny_abnb.airbnb_name, ny_abnb.price
order by rank_airbnb2.brewery

select * from airbnb_rank1
































