USE "credit_risk"


/*
Author : David Losasa
Object :  Praparing data using sql Before cleaning
*/

/*
APPLICATION_RECORD
Creating a copy of application_record with one new column row_num for identifying dulicated values
*/
IF OBJECT_ID('dbo.prepare','U')
IS NULL
BEGIN
	CREATE TABLE [dbo].[prepare](
	[ID] [int] NOT NULL,
	[CODE_GENDER] [nvarchar](50) NOT NULL,
	[FLAG_OWN_CAR] [nvarchar](50) NOT NULL,
	[FLAG_OWN_REALTY] [nvarchar](50) NOT NULL,
	[CNT_CHILDREN] [int] NOT NULL,
	[AMT_INCOME_TOTAL] [nvarchar](50) NOT NULL,
	[NAME_INCOME_TYPE] [nvarchar](50) NOT NULL,
	[NAME_EDUCATION_TYPE] [nvarchar](50) NOT NULL,
	[NAME_FAMILY_STATUS] [nvarchar](50) NOT NULL,
	[NAME_HOUSING_TYPE] [nvarchar](50) NOT NULL,
	[DAYS_BIRTH] [int] NOT NULL,
	[DAYS_EMPLOYED] [int] NOT NULL,
	[FLAG_MOBIL] [int] NOT NULL,
	[FLAG_WORK_PHONE] [int] NOT NULL,
	[FLAG_PHONE] [int] NOT NULL,
	[FLAG_EMAIL] [int] NOT NULL,
	[OCCUPATION_TYPE] [nvarchar](50) NULL,
	[CNT_FAM_MEMBERS] [nvarchar](50) NOT NULL,
	[ROW_NUM] [int] NOT NULL
)
END;

DELETE FROM prepare;

WITH duplicated_application AS (
	SELECT DISTINCT *,  ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS row_num
	FROM application_record
)
INSERT INTO prepare SELECT * FROM duplicated_application WHERE row_num <2;

ALTER TABLE prepare
DROP COLUMN row_num;


/*
Transforming columns into good format
*/


-- "CODE_GENDER" to "Gender" 

EXEC sp_rename 'prepare.CODE_GENDER','GENDER','COLUMN';

UPDATE prepare
SET GENDER = 'Male' WHERE GENDER='M';

UPDATE prepare 
SET GENDER = 'Female' WHERE GENDER='F';

SELECT * FROM [prepare] ;
-- "FLAG_OWN_CAR" to "OWN_CAR"

EXEC sp_rename 'prepare.FLAG_OWN_CAR','OWN_CAR','COLUMN';


UPDATE [prepare]
SET [OWN_CAR] = 'No' WHERE [OWN_CAR] = 'N';

UPDATE [prepare]
SET "OWN_CAR" = 'Yes' WHERE "OWN_CAR" = 'Y';

-- FLAG_OWN_REALTY to "OWN_PROPERTY"
EXEC sp_rename 'prepare.FLAG_OWN_REALTY','OWN_PROPERTY','COLUMN';


UPDATE [prepare]
SET [OWN_PROPERTY] = 'No' WHERE [OWN_PROPERTY] = 'N';

UPDATE [prepare]
SET "OWN_PROPERTY" = 'Yes' WHERE "OWN_PROPERTY" = 'Y';


-- AMT_INCOME_TOTAL
-- Creating new column INCOME with float type

ALTER TABLE [prepare]
ADD INCOME DECIMAL(18,2) NULL;


WITH new_INCOME AS(
    SELECT 
        ID, 
        CAST(REPLACE(AMT_INCOME_TOTAL, '.', '') AS int) AS new_income
    FROM prepare
)
UPDATE d
SET d.INCOME = n.new_income
FROM prepare d
INNER JOIN new_INCOME n ON d.ID = n.ID;


ALTER TABLE prepare
DROP COLUMN AMT_INCOME_TOTAL;



-- NAME_INCOME_TYPE TO INCOME_TYPE 

EXEC sp_rename 'prepare.NAME_INCOME_TYPE','INCOME_TYPE','COLUMN';



-- NAME_EDUCATION_TYPE TO EDUCATION_TYPE 
-- renaming Secondary / secondary special to Secondary
EXEC sp_rename 'prepare.NAME_EDUCATION_TYPE','EDUCATION_TYPE','COLUMN';

UPDATE prepare
SET EDUCATION_TYPE = 'Secondary'
WHERE EDUCATION_TYPE = 'Secondary / secondary special';
;



SELECT DISTINCT EDUCATION_TYPE FROM prepare;



-- NAME_FAMILY_STATUS to FAMILY_STATUS

EXEC sp_rename 'prepare.NAME_FAMILY_STATUS','FAMILY_STATUS','COLUMN';

UPDATE prepare
SET FAMILY_STATUS = 'Single'
WHERE FAMILY_STATUS = 'Single / not married';


--- NAME_HOUSING_TYPE to HOUSING_TYPE
EXEC sp_rename 'prepare.NAME_HOUSING_TYPE','HOUSING_TYPE','COLUMN';


-- DAYS_BIRTH
-- CREATING AGE COLUMN

ALTER TABLE prepare
ADD AGE int;


WITH AGE_CTE AS(
	SELECT * ,CAST(LEFT(CAST(GETDATE() AS DATE),4)AS int)-LEFT(DATEADD(DAY,DAYS_BIRTH,CAST(GETDATE() AS DATE)),4) AS age_cte
	FROM prepare
	WHERE DAYS_BIRTH < 0
)
UPDATE d
SET d.AGE = a.age_cte
FROM prepare d
INNER JOIN AGE_CTE a 
ON d.ID = a.ID
;

ALTER TABLE [prepare]
DROP COLUMN DAYS_BIRTH;


-- DAYS_EMPLOYED
--Creating column EMPLOYE_DURATION

ALTER TABLE prepare
ADD EMPLOYE_DURATION int;

WITH EMPLOYE_CTE AS (
	SELECT *,CAST(LEFT(CAST(GETDATE() AS DATE),4)AS int)-LEFT(DATEADD(DAY,DAYS_EMPLOYED,CAST(GETDATE() AS DATE)),4) AS emp_length
	FROM [prepare]
	WHERE DAYS_EMPLOYED < 0
)
UPDATE d
SET d.EMPLOYE_DURATION = e.emp_length
FROM prepare d
INNER JOIN EMPLOYE_CTE e
ON d.ID =e.ID;

ALTER TABLE prepare
DROP COLUMN DAYS_EMPLOYED;




-- FLAG_MOBILE
-- Removing the column beacause it has only one value
ALTER TABLE prepare
DROP COLUMN FLAG_MOBIL;


SELECT DISTINCT FLAG_MOBIL FROm prepare;

-- FLAG_WORK_PHONE to WORK_PHONE
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepare
ADD WORK_PHONE VARCHAR(5);


WITH PHONE_CTE AS(
	SELECT *,CAST(FLAG_WORK_PHONE AS VARCHAR) AS work_p FROM prepare
)
UPDATE d
SET d.WORK_PHONE = p.work_p
FROM prepare d
INNER JOIN PHONE_CTE p
ON d.ID = p.ID;

UPDATE prepare
SET WORK_PHONE = 'Yes' WHERE WORK_PHONE = '1';

UPDATE prepare
SET WORK_PHONE = 'No' WHERE WORK_PHONE = '0';

ALTER TABLE prepare
DROP COLUMN FLAG_WORK_PHONE;


-- FLAG_PHONE to PHONE
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepare
ADD PHONE VARCHAR(4);

WITH PHONE_CTE AS(
	SELECT *,CAST(FLAG_PHONE AS VARCHAR) AS work_p FROM prepare
)
UPDATE d
SET d.PHONE = p.work_p
FROM prepare d
INNER JOIN PHONE_CTE p
ON d.ID = p.ID;

UPDATE prepare
SET PHONE = 'Yes' WHERE PHONE ='1';

UPDATE prepare
SET PHONE = 'No' WHERE PHONE ='0';

ALTER TABLE prepare
DROP COLUMN FLAG_PHONE;


--
-- FLAG_EMAIL to EMAIL
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepare
ADD EMAIL VARCHAR(4);

WITH EMAIL_CTE AS(
	SELECT *,CAST(FLAG_EMAIL AS VARCHAR) AS email_p FROM prepare
)
UPDATE d
SET d.EMAIL = e.email_p
FROM prepare d
INNER JOIN EMAIL_CTE e
ON d.ID = e.ID;
--
UPDATE prepare
SET EMAIL = 'Yes' WHERE EMAIL ='1';

UPDATE prepare
SET EMAIL = 'No' WHERE EMAIL ='0';

ALTER TABLE prepare
DROP COLUMN FLAG_EMAIL;


--CNT_FAM_MEMBERS to FAMILY_MEMBERS

ALTER TABLE [prepare]
ADD FAMILY_MEMBERS int NULL;

WITH NEW_FAMILY_MEMBERS AS(
    SELECT 
        ID, 
        CAST(REPLACE(CNT_FAM_MEMBERS, '.0', '') AS int) AS new_fam_members
    FROM prepare
)
UPDATE d
SET d.FAMILY_MEMBERS = n.new_fam_members
FROM prepare d
INNER JOIN NEW_FAMILY_MEMBERS n ON d.ID = n.ID;


ALTER TABLE prepare
DROP COLUMN CNT_FAM_MEMBERS;


SELECT DISTINCT FAMILY_MEMBERS FROM prepare;

SELECT * FROM prepare
ORDER BY ID
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;
