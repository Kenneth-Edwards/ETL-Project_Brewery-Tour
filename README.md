# ETL-project: Brewery-hopping and AirBNB in NY
# Saba Tassawar, Andy Spatz, Kenneth Edwards

## Project Scenario:

A client of Extraordinary Tours LLC. has asked us to provide a tour list of the Breweries operating in New York City and a list of nearby AirBNB rental locations in order to identify one within walking distance of the brewery and including the price for one night's stay.


## Extract: 
### Brewery Data
Used CSV brewery data from Kaggle (https://www.kaggle.com/brkurzawa/us-breweries) 
### NYC-AirBNB Data
Used CSV NYC-AirBNB data from Kaggle (https://www.kaggle.com/dgomonov/new-york-city-airbnb-open-data)
### Google Maps API
Used Google Maps APIs in order to measure the distances between the breweries and AirBNB locations.


## Transform:
### Brewery Data
The brewery data from Kaggle was imported into a dataframe and all breweries other than those in New York state were filtered out.
The address (all in one field) was parsed into separate columns and then filtered for simplicity.
Resulting dataframe was uploaded into table "ny_breweries" in Postgres.

After review of the details we found 4 addresses needed to be scrubbed. The detailed corrections are found in excel spreadsheet "nybrews corrections.xlsx"
While in excel we further reduced the records in the corrected csv file to only breweries in New York City. 
This updated file is named "nybrews_4api_file2.csv".

Next we imported the updated CSV file into a dataframe, dropped 2 unnecessary columns and proceeded to use Google Maps API to extract the latitudes and Longitudes for the address of each brewery.

This was transferred to Postgres etlproj_db creating a final brewery table (ny_brews2) for SQL queries.

Table columns:  Brewery name, address, town, and zip code

### AirBnB Data
The AirBnB data from Kaggle was imported into dataframe "AB_NYC_2019_data_df" and cleaned up.

Next we transferred the data to Postgres etlproj_db to create table (ny_abnb) for SQL queries.

Table columns: AirBNB id, property name, host id, town, neighborhood, latitude, longitude, price, monthly reviews, and number of days available per year.

### Data Wrangling
Using SQLAlchemy cross joined our tables in Postgres (ny_brews2 & ny_abnb) mapping every AirBnB in New York City to each of the 17 Breweries on our tour list based on latitude and longitude. ("crossjoin_df" contains 831215 rows = 17 breweries * 48895 AirBnB's)

From the cross-joined dataframe, we created a list containing the Brewery name, the AirBnB_id and the latitude and longitude of both.
From this list we created a new DataFrame "crossjoin_df2", cleaned up the column headers. 

Next we used a for loop and the HAVERSINE function on dataframe crossjoin_df2 to calculate the distance between each brewery and each AirBnB and creating dataframe "crossjoin_df4". (This calculation takes about 1.5 hrs. After the fact we determined that if we had filtered out all AirBnB's outside of New York City this would have significantly reduces this processing interval.) Database "crossjoin_df4" was transferred into Postgres.

Using code provided by a Senior Developer (ZD) we now had a query and created table "rank_airbnb1" which identified the Airbnb by distance from each brewery and assigned a rank to each Airbnb; #1 being the Airbnb closest to the Brewery.

Using SQL we created a new table (airbnb_rank1) by joining table "rank_airbnb2" with "ny_abnb". This provided us with the #1 Ranked Airbnb for each Brewery on the tourlist along with the distance between them calculated in feet.

Transferred data in table "airbnb_rank1" to dataframe "air_rank1_df", MERGED "air_rank1_df" with cross joined dataframe "crossjoin_df4". Then using the lambda function we extracted the unique row from the data which provided the geo coordinates of our brewery and #1 Ranked Airbnb. Each of these rows are concatenated using Pandas to create a new dataframe with cleaned headers and dropped unecessary columns (brewsjoined_df2).

From brewsjoined_df2 we used the ".tolist()" method to create lists for the Latitude and Longitude of both the Breweries and AirBnB's on our tour list. We then incorporated the geocordinates with googlemaps again to create two heat maps, one for the breweries and one for the AirBnB's.

Heat Map file names are brew_map.htm and airbnb_map.html. Viewable PNG screen shots are available as well (Breweries_HeatMap.png & AirBnB_HeatMap.png).

![Image description](https://github.com/SabaTass/ETL-project/blob/master/Pics/Breweries_HeatMap.PNG)

![Image description](https://github.com/SabaTass/ETL-project/blob/master/Pics/AirBnB_HeatMap.PNG)


## Load: 

Final step was to transfer this data back to Postgres, creating a new table called "brewery_tour_list", where it can be stored and called upon again for any future client interested in the same Brewery Tour.  We decided to use relational databases (SQL/Postgres) rather than non-relational (Mongo) because we already had CSV columns with headings, which allowed for easy upload and joining of data.

## Final ERD Schema

![Image description](https://github.com/SabaTass/ETL-project/blob/master/brewery_erd.png) 
