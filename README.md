# ETL-project: Brewery-hopping and AirBNB in NY
# Saba Tassawar, Andy Spatz, Kenneth Edwards

## Project Scenario:

A client of Extraordinary Tours LLC. has asked us to provide a tour list of the Breweries operating in New York City and then find a list of New York City Airbnb's in order to identify the closest one within walking distance and also provide the price for one night's stay.


## Extract: 
### Brewery Data
Used brewery data from Kaggle (https://www.kaggle.com/brkurzawa/us-breweries and/or        https://www.kaggle.com/ehallmar/beers-breweries-and-beer-reviews#breweries.csv) 
### NYC-AirBNB Data
Used NYC-AirBNB data from Kaggle (https://www.kaggle.com/dgomonov/new-york-city-airbnb-open-data)


## Transform:

### Brewery Data
The brewery data from Kaggle was imported into a dataframe and all breweries other than those in New York state were filtered out.
The address (all in one field) was parsed.
Resulting dataframe was used to create table "ny_breweries" in Postgres

After review of the details we found 4 addresses needed to be scrubbed. The detailed corrections are found in excel spreadsheet "nybrews corrections.xlsx". 

While in excel we further reduced the records in the corrected csv file to only breweries in New York City. 
This updated file is named "nybrews_4api_file2.csv".

Next we imported the updated CSV file into a dataframe, dropped 2 unnecessary columns and proceeded to use our Google API-KEY and googlemaps to extract the Latitude and Longitude for the address of each brewery.

This was transferred to Postgres etlproj_db creating a table (ny_brews2) for SQL queries.

### AirBnB Data
The AirBnB data from Kaggle.com is in "AB_NYC_2019.csv" This file was imported into dataframe "AB_NYC_2019_data_df" and column headers renamed.

Next we transferred the data to Postres etlproj_db to create table (ny_abnb) for query purposes

### Data Wrangling
Using SQLAlchemy magic we performed a CROSS JOIN of our two tables in Postgres (ny_brews2 & ny_abnb) mapping every AirBnB in New York State to each of the 17 Breweries on our tour list. ("crossjoin_df" contains 831215 rows = 17 breweries * 48895 AirBnB's)

From the crossjoined dataframe we created a LIST containing the Brewery name, the AirBnB_id and the latitude and longitude of both.
From this list we created a new DataFrame "crossjoin_df2", cleaned up the column headers. 

Next we performed a for loop utilizing iterrows and the HAVERSINE function on dataframe crossjoin_df2 to calculate the distance between each brewery and each New York AirBnB. (This calculation takes about 1.5 hrs. After the fact we determined that if we had filtered out all AirBnB's outside of New York City this would have significantly reduces this processing interval.)

Used a single pair of coodinates and the HAVERSINE function to confirm accuracy of our results. ( On the first two passes we found copy/paste and typo errors that had to be corrected and required the 1.5 hr 'for loop' to be run again.) Final output is in dataframe "crossjoin_df4".

"crossjoin_df4" is next transferred into Postgres.

Using code provided by a Senior Developer (ZD) we now had a query and created table "rank_airbnb1" which identified the Airbnb by distance from each brewery and assigned a rank to each Airbnb; #1 being the Airbnb closest to the Brewery.

Using SQL we created a new table (airbnb_rank1) by joining table "rank_airbnb2" with "ny_abnb". This provided us with the #1 Ranked Airbnb for each Brewery on the tourlist along with the distance between them calculated in feet.

Transferred data in table "airbnb_rank1" to dataframe "air_rank1_df", MERGED "air_rank1_df" with cross joined dataframe "crossjoin_df4". Then using the lambda function we extracted the unique row from the data which provided the geo coordinates of our brewery and #1 Ranked Airbnb. Each of these rows are concatenated using Pandas to create a new dataframe with cleaned headers and dropped unecessary columns (brewsjoined_df2).

From brewsjoined_df2 we used the ".tolist()" method to create lists for the Latitude and Longitude of both the Breweries and AirBnB's on our tour list. We then incorporated the geocordinates with googlemaps again to create two heat maps, one for the breweries and one for the AirBnB's.
* Heat Map file names are brew_map.htm and airbnb_map.html. Viewable PNG screen shots are available as well (Breweries_HeatMap.png & AirBnB_HeatMap.png).

![Image description](https://github.com/SabaTass/ETL-project/blob/master/Breweries_HeatMap.PNG)

![Image description](https://github.com/SabaTass/ETL-project/blob/master/AirBnB_HeatMap.PNG)


## Load: 

Final step was to transfer this data back to Postgres, creating a new table called "brewery_tour_list", where it can be stored and called upon again for any future client interested in the same Brewery Tour.
