--***Create tables
--**_temp
DROP TABLE public._temp;
CREATE TABLE public._temp (
	vin VARCHAR(30),
	county VARCHAR(50),
	city VARCHAR(50),
	us_state VARCHAR(10),
	p_code VARCHAR(10),
	model_year INTEGER,
	make VARCHAR(50),
	model VARCHAR(50),
	ev_type VARCHAR(150),
	elig VARCHAR(150),
	ev_range INTEGER,
	msrp INTEGER,
	district VARCHAR(10),
	dol_vin VARCHAR(30),
	pc_point VARCHAR(200),
	electric_ut VARCHAR(200),
	census_tract_2020 VARCHAR(30)
);

SELECT *, DENSE_RANK() OVER (ORDER BY census_tract_2020, p_code, city, county, 
							  us_state, district, pc_point) AS owner_loc_id
FROM _temp
--**Read in the data (use command line instead of GUI)**
\copy _temp 
FROM 'C:/Users/dylbe/Documents/SQL Tableau Project/Data/evp_WA_2024.csv'
DELIMITER ','
CSV HEADER

--**ev  ev M <-> 1 owner_loc
DROP TABLE public.ev;
CREATE TABLE public.ev (
	dol_vin VARCHAR(30) PRIMARY KEY,
	vin VARCHAR(30),
	model_year INTEGER,
	make VARCHAR(50),
	model VARCHAR(50),
	ev_type VARCHAR(150),
	elig VARCHAR(150),
	ev_range INTEGER,
	msrp INTEGER,
	electric_ut VARCHAR(200),
	owner_loc_id BIGINT,
	CONSTRAINT ol_id_fk 
		FOREIGN KEY (owner_loc_id)
			REFERENCES owner_loc(owner_loc_id)
);
INSERT INTO public.ev (dol_vin, vin, model_year, make, model, ev_type, elig, ev_range, msrp, electric_ut, owner_loc_id)
WITH _temp_ol_id AS (
SELECT *, DENSE_RANK() OVER (ORDER BY census_tract_2020, p_code, city, county, 
							  us_state, district, pc_point) AS owner_loc_id
FROM _temp)
SELECT dol_vin, vin, model_year, make, model, ev_type, elig, ev_range, msrp, electric_ut, owner_loc_id
FROM _temp_ol_id;
	

--**owner_loc** ev M <-> 1 owner_loc 
DROP TABLE public.owner_loc;
CREATE TABLE public.owner_loc (
	owner_loc_id BIGINT PRIMARY KEY,
	census_tract_2020 VARCHAR(30),
	p_code VARCHAR(10),
	city VARCHAR(50),
	county VARCHAR(50),
	us_state VARCHAR(10),
	district VARCHAR(10),
	pc_point VARCHAR(200)
);
INSERT INTO public.owner_loc (owner_loc_id, census_tract_2020, p_code, city, county, 
							  us_state, district, pc_point)
WITH _temp_ol_id AS (
SELECT *, DENSE_RANK() OVER (ORDER BY census_tract_2020, p_code, city, county, 
							  us_state, district, pc_point) AS owner_loc_id
FROM _temp)
SELECT DISTINCT owner_loc_id, census_tract_2020, p_code, city, county, 
							  us_state, district, pc_point
FROM _temp_ol_id
ORDER BY owner_loc_id;