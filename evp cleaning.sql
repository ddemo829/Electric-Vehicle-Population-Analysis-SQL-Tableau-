--***cleaning ev table
--**dol_vin
SELECT dol_vin, COUNT(*) AS dol_vin_count
FROM ev
GROUP BY dol_vin
HAVING COUNT(*) > 1
ORDER BY dol_vin_count DESC;

SELECT dol_vin, LENGTH(dol_vin) AS dv_len
FROM ev
ORDER BY dol_vin;

UPDATE ev
SET dol_vin = btrim(dol_vin);

--**model_year
SELECT DISTINCT model_year
FROM ev;

--**make
SELECT DISTINCT make
FROM ev;

UPDATE ev
SET make = btrim(make);

--**model
SELECT DISTINCT model
FROM ev;

UPDATE ev
SET model = btrim(model);

--**ev_type
SELECT DISTINCT ev_type
FROM ev;

--**elig
SELECT DISTINCT elig
FROM ev;

UPDATE ev
SET elig = btrim(elig);

--**ev_range
SELECT ev_range, make, model, model_year
FROM ev
WHERE ev_range = 0;

SELECT ev_range, NULLIF(ev_range, 0), make, model
FROM ev
WHERE ev_range = 0;

UPDATE ev
SET ev_range = NULLIF(ev_range, 0);

--**msrp
SELECT msrp, make, model, model_year
FROM ev
WHERE msrp = 0;

SELECT msrp, NULLIF(msrp, 0), make, model
FROM ev
WHERE msrp = 0;

UPDATE ev
SET msrp = NULLIF(msrp, 0);

--***Cleaning owner_loc
--**county
SELECT DISTINCT county, us_state
FROM owner_loc
ORDER BY county;

UPDATE owner_loc
SET county = btrim(county);

--**city
SELECT DISTINCT city, us_state
FROM owner_loc 
ORDER BY city;

UPDATE owner_loc
SET city = btrim(city);

--**us_state
SELECT DISTINCT us_state 
FROM _temp;

SELECT us_state, LENGTH(us_state) 
FROM owner_loc 
WHERE LENGTH(us_state) <> 2
ORDER BY us_state;

--**p_code
SELECT p_code, LENGTH(p_code) AS pc_len
FROM owner_loc
WHERE LENGTH(p_code) <> 5
ORDER BY p_code;

SELECT '0' || p_code AS zero_pc
FROM owner_loc
WHERE LENGTH(p_code) <> 5;

UPDATE owner_loc
SET p_code = '0' || p_code
WHERE LENGTH(p_code) <> 5;

--**pc_point
SELECT pc_point, SUBSTRING(pc_point, 8, LENGTH(pc_point) - 8),
SPLIT_PART(SUBSTRING(pc_point, 8, LENGTH(pc_point) - 8), ' ', 1), 
SPLIT_PART(SUBSTRING(pc_point, 8, LENGTH(pc_point) - 8), ' ', 2)
FROM owner_loc;

ALTER TABLE owner_loc
ADD longitude NUMERIC(10, 6);

UPDATE owner_loc
SET longitude = SPLIT_PART(SUBSTRING(pc_point, 8, LENGTH(pc_point) - 8), ' ', 1)::NUMERIC(10, 6);

ALTER TABLE owner_loc
ADD latitude NUMERIC(10, 6);

UPDATE owner_loc
SET latitude = SPLIT_PART(SUBSTRING(pc_point, 8, LENGTH(pc_point) - 8), ' ', 2)::NUMERIC(10, 6);

ALTER TABLE owner_loc
DROP pc_point;

--**district
SELECT DISTINCT district
FROM owner_loc;

--**census_tract_2020
SELECT census_tract_2020, LENGTH(census_tract_2020)
FROM owner_loc
WHERE LENGTH(census_tract_2020) <> 11;

--**export data
/copy (SELECT ev.dol_vin, ol.owner_loc_id, ev.vin, ev.model_year, ev.make, ev.model, 
ev.ev_type, ev.elig, ev.ev_range, ev.msrp, ev.electric_ut, 
ol.census_tract_2020, ol.p_code, ol.city, ol.county, 
ol.us_state, ol.district, ol.longitude, ol.latitude
FROM ev INNER JOIN owner_loc AS ol ON ev.owner_loc_id = ol.owner_loc_id)
TO 'C:/Users/dylbe/Documents/SQL Tableau Project/Data/evp_WA_clean.csv'
DELIMITER ',' CSV HEADER;
