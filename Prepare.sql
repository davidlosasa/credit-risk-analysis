USE "credit_risk"


/*
Author : David Losasa
Object :  Praparing data using sql Before cleaning
*/


/*
APPLICATION_RECORD
Creating a copy of application_record with one new column row_num for identifying dulicated values
*/
IF OBJECT_ID('dbo.prepared_application_record','U')
IS NULL
BEGIN
	CREATE TABLE [dbo].prepared_application_record(
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

DELETE FROM prepared_application_record;

WITH duplicated_application AS (
	SELECT DISTINCT *,  ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS row_num
	FROM application_record
)
INSERT INTO prepared_application_record SELECT * FROM duplicated_application WHERE row_num <2;


ALTER TABLE prepared_application_record
DROP COLUMN row_num;


/*
Transforming columns into good format
*/


-- "CODE_GENDER" to "Gender" 

EXEC sp_rename 'prepared_application_record.CODE_GENDER','GENDER','COLUMN';


UPDATE prepared_application_record
SET GENDER = 'Male' WHERE GENDER='M';

UPDATE prepared_application_record
SET GENDER = 'Female' WHERE GENDER='F';

-- "FLAG_OWN_CAR" to "OWN_CAR"

EXEC sp_rename 'prepared_application_record.FLAG_OWN_CAR','OWN_CAR','COLUMN';


UPDATE prepared_application_record
SET [OWN_CAR] = 'No' WHERE [OWN_CAR] = 'N';

UPDATE prepared_application_record
SET "OWN_CAR" = 'Yes' WHERE "OWN_CAR" = 'Y';

-- FLAG_OWN_REALTY to "OWN_PROPERTY"
EXEC sp_rename 'prepared_application_record.FLAG_OWN_REALTY','OWN_PROPERTY','COLUMN';


UPDATE prepared_application_record
SET [OWN_PROPERTY] = 'No' WHERE [OWN_PROPERTY] = 'N';

UPDATE prepared_application_record
SET "OWN_PROPERTY" = 'Yes' WHERE "OWN_PROPERTY" = 'Y';


-- AMT_INCOME_TOTAL
-- Creating new column INCOME with float type

ALTER TABLE prepared_application_record
ADD INCOME DECIMAL(18,2) NULL;


WITH new_INCOME AS(
    SELECT 
        ID, 
        CAST(REPLACE(AMT_INCOME_TOTAL, '.', '') AS int) AS new_income
    FROM prepared_application_record
)
UPDATE d
SET d.INCOME = n.new_income
FROM prepared_application_record d
INNER JOIN new_INCOME n ON d.ID = n.ID;



ALTER TABLE prepared_application_record
DROP COLUMN AMT_INCOME_TOTAL;



-- NAME_INCOME_TYPE TO INCOME_TYPE 

EXEC sp_rename 'prepared_application_record.NAME_INCOME_TYPE','INCOME_TYPE','COLUMN';



-- NAME_EDUCATION_TYPE TO EDUCATION_TYPE 
-- renaming Secondary / secondary special to Secondary
EXEC sp_rename 'prepared_application_record.NAME_EDUCATION_TYPE','EDUCATION_TYPE','COLUMN';

UPDATE prepared_application_record
SET EDUCATION_TYPE = 'Secondary'
WHERE EDUCATION_TYPE = 'Secondary / secondary special';
;




-- NAME_FAMILY_STATUS to FAMILY_STATUS

EXEC sp_rename 'prepared_application_record.NAME_FAMILY_STATUS','FAMILY_STATUS','COLUMN';

UPDATE prepared_application_record
SET FAMILY_STATUS = 'Single'
WHERE FAMILY_STATUS = 'Single / not married';


--- NAME_HOUSING_TYPE to HOUSING_TYPE


-- DAYS_BIRTH
-- CREATING AGE COLUMN

ALTER TABLE prepared_application_record
ADD AGE int;


WITH AGE_CTE AS(
	SELECT * ,CAST(LEFT(CAST(GETDATE() AS DATE),4)AS int)-LEFT(DATEADD(DAY,DAYS_BIRTH,CAST(GETDATE() AS DATE)),4) AS age_cte
	FROM prepared_application_record
	WHERE DAYS_BIRTH < 0
)
UPDATE d
SET d.AGE = a.age_cte
FROM prepared_application_record d
INNER JOIN AGE_CTE a 
ON d.ID = a.ID
;

ALTER TABLE prepared_application_record
DROP COLUMN DAYS_BIRTH;


-- DAYS_EMPLOYED
--Creating column EMPLOYE_DURATION

ALTER TABLE prepared_application_record
ADD EMPLOYE_DURATION int;

WITH EMPLOYE_CTE AS (
	SELECT *,CAST(LEFT(CAST(GETDATE() AS DATE),4)AS int)-LEFT(DATEADD(DAY,DAYS_EMPLOYED,CAST(GETDATE() AS DATE)),4) AS emp_length
	FROM prepared_application_record
	WHERE DAYS_EMPLOYED < 0
)
UPDATE d
SET d.EMPLOYE_DURATION = e.emp_length
FROM prepared_application_record d
INNER JOIN EMPLOYE_CTE e
ON d.ID =e.ID;

ALTER TABLE prepared_application_record
DROP COLUMN DAYS_EMPLOYED;




-- FLAG_MOBILE
-- Removing the column beacause it has only one value
ALTER TABLE prepared_application_record
DROP COLUMN FLAG_MOBIL;


-- FLAG_WORK_PHONE to WORK_PHONE
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepared_application_record
ADD WORK_PHONE VARCHAR(5);


WITH PHONE_CTE AS(
	SELECT *,CAST(FLAG_WORK_PHONE AS VARCHAR) AS work_p FROM prepared_application_record
)
UPDATE d
SET d.WORK_PHONE = p.work_p
FROM prepared_application_record d
INNER JOIN PHONE_CTE p
ON d.ID = p.ID;

UPDATE prepared_application_record
SET WORK_PHONE = 'Yes' WHERE WORK_PHONE = '1';


UPDATE prepared_application_record
SET WORK_PHONE = 'No' WHERE WORK_PHONE = '0';

ALTER TABLE prepared_application_record
DROP COLUMN FLAG_WORK_PHONE;


-- FLAG_PHONE to PHONE
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepared_application_record
ADD PHONE VARCHAR(4);

WITH PHONE_CTE AS(
	SELECT *,CAST(FLAG_PHONE AS VARCHAR) AS work_p FROM prepared_application_record
)
UPDATE d
SET d.PHONE = p.work_p
FROM prepared_application_record d
INNER JOIN PHONE_CTE p
ON d.ID = p.ID;

UPDATE prepared_application_record
SET PHONE = 'Yes' WHERE PHONE ='1';

UPDATE prepared_application_record
SET PHONE = 'No' WHERE PHONE ='0';

ALTER TABLE prepared_application_record
DROP COLUMN FLAG_PHONE;


--
-- FLAG_EMAIL to EMAIL
-- Changing 1 to YES and 0 to NO

ALTER TABLE prepared_application_record
ADD EMAIL VARCHAR(4);

WITH EMAIL_CTE AS(
	SELECT *,CAST(FLAG_EMAIL AS VARCHAR) AS email_p FROM prepared_application_record
)
UPDATE d
SET d.EMAIL = e.email_p
FROM prepared_application_record d
INNER JOIN EMAIL_CTE e
ON d.ID = e.ID;


UPDATE prepared_application_record
SET EMAIL = 'Yes' WHERE EMAIL ='1';

UPDATE prepared_application_record
SET EMAIL = 'No' WHERE EMAIL ='0';

ALTER TABLE prepared_application_record
DROP COLUMN FLAG_EMAIL;


--CNT_FAM_MEMBERS to FAMILY_MEMBERS

ALTER TABLE prepared_application_record
ADD FAMILY_MEMBERS int NULL;

WITH NEW_FAMILY_MEMBERS AS(
    SELECT 
        ID, 
        CAST(REPLACE(CNT_FAM_MEMBERS, '.0', '') AS int) AS new_fam_members
    FROM prepared_application_record
)
UPDATE d
SET d.FAMILY_MEMBERS = n.new_fam_members
FROM prepared_application_record d
INNER JOIN NEW_FAMILY_MEMBERS n ON d.ID = n.ID;



ALTER TABLE prepared_application_record
DROP COLUMN CNT_FAM_MEMBERS;


-- ---------------------------------
SELECT DISTINCT FAMILY_MEMBERS FROM prepared_application_record;

SELECT * FROM prepared_application_record
ORDER BY ID
OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;

--------------------------

/*
CREDIT_RECORD
Creating a copy of credit_record with one new column row_num for identifying dulicated values
*/

IF OBJECT_ID('dbo.prepared_credit_record','U')
IS NULL
BEGIN
CREATE TABLE [dbo].[prepared_credit_record](
	[ID] [int] NOT NULL,
	[MONTHS_BALANCE] [int] NULL,
	[STATUS] [nvarchar](50) NULL
) ON [PRIMARY]
END;

WITH credit_record_cte AS(
	SELECT *
	FROM credit_record
)
INSERT INTO prepared_credit_record
SELECT * FROM credit_record_cte;
-------------------------------------------------------
-- Creating new Months_balance column



ALTER TABLE prepared_credit_record
ADD MONTH_BALANCE DATE;


WITH MONTH_CTE AS(
SELECT *,DATEADD(DAY,MONTHS_BALANCE,CAST(GETDATE()AS DATE)) AS real_month
FROM prepared_credit_record 
)
UPDATE p
SET p.MONTH_BALANCE = m.real_month
FROM prepared_credit_record p
INNER JOIN MONTH_CTE m ON
p.ID = m.ID AND p."STATUS"=m."STATUS" AND p.MONTHS_BALANCE = m.MONTHS_BALANCE;

ALTER TABLE prepared_credit_record
DROP COLUMN MONTHS_BALANCE;


-- UPDATING VALUES IN status column for making it more clear

UPDATE prepared_credit_record
SET "STATUS" = '1-29 days past due' WHERE "STATUS" = '0';

UPDATE prepared_credit_record
SET "STATUS" = '30-59 days past due' WHERE "STATUS" = '1';

UPDATE prepared_credit_record
SET "STATUS" = '60-89 days past due' WHERE "STATUS" = '2';

UPDATE prepared_credit_record
SET "STATUS" = '90-119 days overdue' WHERE "STATUS" = '3';

UPDATE prepared_credit_record
SET "STATUS" = '120-149 days overdue' WHERE "STATUS" = '4';

UPDATE prepared_credit_record
SET "STATUS" = 'Bad debt' WHERE "STATUS" = '5';

UPDATE prepared_credit_record
SET "STATUS" = 'Paid off that month' WHERE "STATUS" = 'C';

UPDATE prepared_credit_record
SET "STATUS" = 'No loan for the month' WHERE "STATUS" = 'X';

SELECT * FROM prepared_credit_record;

--- Merging two table into one to export

WITH merged_cte AS (
SELECT
	p.ID,
	p.GENDER,
	p.OWN_CAR,
	p.OWN_PROPERTY,
	p.CNT_CHILDREN,
	p.INCOME_TYPE,
	p.EDUCATION_TYPE,
	p.FAMILY_STATUS,
	p.HOUSING_TYPE,
	p.OCCUPATION_TYPE,
	p.INCOME,
	p.AGE,
	p.EMPLOYE_DURATION,
	p.WORK_PHONE,
	p.PHONE,
	p.EMAIL,
	p.FAMILY_MEMBERS,
	c.MONTH_BALANCE,
	c."STATUS"
FROM prepared_application_record p
INNER JOIN prepared_credit_record c
ON p.ID = c.ID
)
SELECT *
INTO [merged_data]
FROM merged_cte;

SELECT *
FROM [merged_data]

