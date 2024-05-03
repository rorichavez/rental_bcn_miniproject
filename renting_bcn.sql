CREATE DATABASE IF NOT EXISTS renting_bcn;

USE renting_bcn;

CREATE TABLE IF NOT EXISTS district(
district VARCHAR(40),
district_id INT,
PRIMARY KEY (district_id)
);

CREATE TABLE IF NOT EXISTS neighbourhood(
district_id INT, 
neighbourhood VARCHAR(40),
neighbourhood_id INT,
PRIMARY KEY (neighbourhood_id)
 -- FOREIGN KEY (district_id) REFERENCES district(district_id)
);

CREATE TABLE IF NOT EXISTS rent(
neighbourhood_id INT,
district_id INT,
price_avg FLOAT,
rent_id INT,
PRIMARY KEY (rent_id)
 -- FOREIGN KEY (district_id) REFERENCES district(district_id),
 -- FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(neighbourhood_id)
);

CREATE TABLE IF NOT EXISTS population(
neighbourhood_id INT,
population_id INT,
population FLOAT,
spaniards FLOAT,
strangers FLOAT,
PRIMARY KEY (population_id)
 -- FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(neighbourhood_id)
);

CREATE TABLE IF NOT EXISTS airbnb(
type VARCHAR(80),
name VARCHAR(80),
nhab VARCHAR(80),
services VARCHAR(80),
rating FLOAT,
price_night INT,
district_id INT,
airbnb_id INT,
PRIMARY KEY (airbnb_id)
-- FOREIGN KEY (district_id) REFERENCES district(district_id)
);

# ADD FOREIGN KEYS.

ALTER TABLE neighbourhood
ADD FOREIGN KEY (district_id) REFERENCES district (district_id);

ALTER TABLE rent
ADD FOREIGN KEY (district_id) REFERENCES district(district_id);

ALTER TABLE rent
ADD FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(neighbourhood_id);

ALTER TABLE population
ADD FOREIGN KEY (neighbourhood_id) REFERENCES neighbourhood(neighbourhood_id);

ALTER TABLE airbnb
ADD FOREIGN KEY (district_id) REFERENCES district(district_id);

-- -- -- -- -- -- -- -- -- -- -- -- 

# QUESTION

-- Distritos con mayor concentración de alquileres turísticos.
CREATE VIEW concentration_tourist AS
SELECT d.district AS name, COUNT(a.airbnb_id) AS total_airbnb
FROM airbnb as a
RIGHT JOIN district AS d
ON a.district_id = d.district_id
GROUP BY d.district;

-- Precios promedio de rent por distrito
 CREATE VIEW price_avg_dis AS
 SELECT
    d.district_id AS district_id,
    d.district AS district,
    FORMAT(AVG(r.price_avg), 2) AS avg_price_€
FROM rent AS r
LEFT JOIN district AS d ON r.district_id = d.district_id
GROUP BY d.district, d.district_id
ORDER BY AVG(r.price_avg) DESC
LIMIT 10;
SELECT * FROM price_avg_dis;

-- Precios promedio de rent por barrio

 CREATE VIEW price_avg_nei AS
 SELECT
    n.neighbourhood_id AS neighbourhood_id,
    n.neighbourhood AS neighbourhood,
    FORMAT(AVG(r.price_avg), 2) AS avg_price_€
FROM rent AS r
LEFT JOIN neighbourhood AS n ON r.neighbourhood_id = n.neighbourhood_id
GROUP BY n.neighbourhood_id, neighbourhood
ORDER BY avg_price_€ DESC
LIMIT 10;

-- Hay más extranjeros o españoles? Dividido por barrio.
CREATE VIEW summary_population AS
	SELECT
    p.neighbourhood_id,
    n.neighbourhood,
    CONCAT(FORMAT((SUM(p.strangers) / SUM(p.population)) * 100, 2), "%") AS foreigner_percentage,
    CONCAT(FORMAT((SUM(p.spaniards) / SUM(p.population)) * 100, 2), "%") AS spaniard_percentage
FROM population AS p
LEFT JOIN neighbourhood AS n ON p.neighbourhood_id = n.neighbourhood_id
GROUP BY p.neighbourhood_id, n.neighbourhood;

# Lo separamos para poder vizualizarlo.
-- %strangers
SELECT
    p.neighbourhood_id,
    n.neighbourhood,
    CONCAT(FORMAT((SUM(p.strangers) / SUM(p.population)) * 100, 2), "%") AS foreigner_percentage
FROM population AS p
LEFT JOIN neighbourhood AS n ON p.neighbourhood_id = n.neighbourhood_id
GROUP BY p.neighbourhood_id, n.neighbourhood;

-- %spaniards
	SELECT
    p.neighbourhood_id,
    n.neighbourhood,
    CONCAT(FORMAT((SUM(p.spaniards) / SUM(p.population)) * 100, 2), "%") AS spaniard_percentage
FROM population AS p
LEFT JOIN neighbourhood AS n ON p.neighbourhood_id = n.neighbourhood_id
GROUP BY p.neighbourhood_id, n.neighbourhood;

-- Precios promedio de airbnb por distrito
 CREATE VIEW avg_prices_airbnb AS
 SELECT
 d.district AS district_name,
 AVG(a.price_night) AS price_night_€
 FROM district AS d
 JOIN airbnb AS a
 ON d.district_id = a.district_id
 GROUP BY d.district
 ORDER BY AVG(a.price_night) DESC;