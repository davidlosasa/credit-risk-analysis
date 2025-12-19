USE credit_risk

-- Managing missing values

-- OCCUPATION_TYPE
SELECT DISTINCT OCCUPATION_TYPE FROM merged_data

UPDATE merged_data 
SET OCCUPATION_TYPE = 'Other'
WHERE OCCUPATION_TYPE IS NULL;

--EMPLOYE_DURATION

DELETE FROM merged_data
WHERE EMPLOYE_DURATION IS NULL;
/*
I choose to delete because there some employe who have 0 like duration,
So i can't just update Null value to 0 
*/


SELECT * FROM cleaned_data;

