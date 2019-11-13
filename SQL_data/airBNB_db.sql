CREATE TABLE airbnb_ny (
	id INT PRIMARY KEY,
	name VARCHAR NOT NULL,
	host_id INT NOT NULL,
	town VARCHAR(40) NOT NULL,
	neighbourhood VARCHAR(40) NOT NULL,
	latitude INT NOT NULL,
	longitude INT NOT NULL,
	price INT NOT NULL,	
	reviews_per_month INT NOT NULL,	
	availability INT NOT NULL
);