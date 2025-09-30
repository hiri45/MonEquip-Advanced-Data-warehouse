CREATE TABLE new_address AS SELECT * FROM MONEQUIP.ADDRESS;
CREATE TABLE new_category AS SELECT * FROM MONEQUIP.category;
CREATE TABLE new_equipment AS SELECT * FROM MONEQUIP.equipment;
CREATE TABLE new_hire AS SELECT * FROM MONEQUIP.hire;
CREATE TABLE new_sales AS SELECT * FROM MONEQUIP.sales;
CREATE TABLE new_staff AS SELECT * FROM MONEQUIP.staff;

-- data cleaning 

-- 1. checking for duplicate records from each table 
-- 1a. check duplicates from address table in operational database
select * FROM MonEquip.ADDRESS;
-- there were no duplicates
select address_id, street_number,upper(street_name), upper(suburb), upper(state), postcode , count(*) AS duplicate
from MONEQUIP.ADDRESS
group by address_id, street_number,upper(street_name), upper(suburb), upper(state), postcode
having count(*) > 1; 


-- 1b. check duplicates from category table in operational database
-- just from looking can see there is none
SELECT * FROM MONEQUIP.CATEGORY;


-- 1c. check duplicates from customer table in operational database
SELECT * FROM MONEQUIP.CUSTOMER;
-- found a duplicate 
select customer_id, customer_type_id,upper(name), upper(gender), address_id, phone, upper(email), count(*) AS duplicate
from MONEQUIP.CUSTOMER
group by customer_id, customer_type_id,upper(name), upper(gender), address_id, phone, upper(email)
having count(*) > 1; 
-- fixing duplicate 
DROP TABLE new_customer;
create table new_customer as
select distinct *
from MONEQUIP.customer; 

select customer_id, customer_type_id,name, gender, address_id, phone, email, count(*) AS duplicate
from new_customer
group by customer_id, customer_type_id,name, gender, address_id, phone, email
having count(*) > 1; 

SELECT * FROM NEW_CUSTOMER;

-- 1d. check duplicates from customer_type table in operational database
SELECT * FROM MONEQUIP.CUSTOMER_TYPE;
-- found duplicate 
select customer_type_id,upper(description), count(*) AS duplicate
from MONEQUIP.CUSTOMER_TYPE
group by customer_type_id,upper(description)
having count(*) > 1; 

-- fixing duplicate
DROP TABLE new_customer_type;

CREATE TABLE new_customer_type AS
SELECT customer_type_id,
       INITCAP(TRIM(description)) AS description
FROM (
    SELECT customer_type_id,
           UPPER(TRIM(description)) AS description_norm,
           MIN(description) AS description
    FROM MONEQUIP.customer_type
    GROUP BY customer_type_id, UPPER(TRIM(description))
);

SELECT * FROM new_customer_type;


-- 1e. check duplicates from equipment table in operational database
SELECT * FROM MONEQUIP.EQUIPMENT;
-- there were no duplicates
select EQUIPMENT_ID ,upper(EQUIPMENT_NAME), EQUIPMENT_PRICE, MANUFACTURE_YEAR , upper(manufacturer),CATEGORY_ID , count(*) AS duplicate
from MONEQUIP.EQUIPMENT
group by EQUIPMENT_ID ,upper(EQUIPMENT_NAME), EQUIPMENT_PRICE, MANUFACTURE_YEAR , upper(manufacturer),CATEGORY_ID
having count(*) > 1; 

-- 1f. check duplicates from hire table in operational database
-- there were no duplicates
SELECT * FROM MONEQUIP.HIRE;
select hire_ID ,start_date, end_date, EQUIPMENT_id, QUANTITY,UNIT_HIRE_PRICE,TOTAL_HIRE_PRICE,CUSTOMER_ID,STAFF_ID ,count(*) AS duplicate
from MONEQUIP.hire
group by hire_ID ,start_date, end_date, EQUIPMENT_id, QUANTITY,UNIT_HIRE_PRICE,TOTAL_HIRE_PRICE,CUSTOMER_ID,STAFF_ID 
having count(*) > 1; 


-- 1g. check duplicates from sales table in operational database
-- there were no duplicates
SELECT * FROM MONEQUIP.SALES;
select hire_ID ,start_date, end_date, EQUIPMENT_id, QUANTITY,UNIT_HIRE_PRICE,TOTAL_HIRE_PRICE,CUSTOMER_ID,STAFF_ID ,count(*) AS duplicate
from MONEQUIP.SALES
group by hire_ID ,start_date, end_date, EQUIPMENT_id, QUANTITY,UNIT_HIRE_PRICE,TOTAL_HIRE_PRICE,CUSTOMER_ID,STAFF_ID 
having count(*) > 1; 
-- relationship problems 

SELECT * FROM MONEQUIP.STAFF;

-- checking CUSTOMER.CUSTOMER_TYPE_ID → CUSTOMER_TYPE.CUSTOMER_TYPE_ID
-- Check for invalid customer type IDs
-- there were no invalid customer type IDs
SELECT *
FROM MONEQUIP.CUSTOMER
WHERE CUSTOMER_TYPE_ID NOT IN (
    SELECT CUSTOMER_TYPE_ID FROM MONEQUIP.CUSTOMER_TYPE
);
-- Check for NULL FKs (if FK should not be NULL)
-- there were no null FKs
SELECT *
FROM MONEQUIP.CUSTOMER
WHERE CUSTOMER_TYPE_ID IS NULL;


-- checking CUSTOMER.ADDRESS_ID → ADDRESS.ADDRESS_ID
-- Check for invalid addresses
-- there were no invalid FKs
SELECT *
FROM MONEQUIP.CUSTOMER
WHERE ADDRESS_ID NOT IN (
    SELECT ADDRESS_ID FROM MONEQUIP.ADDRESS
);
-- Check for NULL FKs
-- no null values 
SELECT *
FROM MONEQUIP.CUSTOMER
WHERE ADDRESS_ID IS NULL;


-- checking EQUIPMENT.CATEGORY_ID → CATEGORY.CATEGORY_ID
-- Check for invalid categories
-- no invalid FKs
SELECT *
FROM MONEQUIP.EQUIPMENT
WHERE CATEGORY_ID NOT IN (
    SELECT CATEGORY_ID FROM MONEQUIP.CATEGORY
);
-- Check for NULL FKs
-- no null FKs
SELECT *
FROM MONEQUIP.EQUIPMENT
WHERE CATEGORY_ID IS NULL;


-- checking SALES.EQUIPMENT_ID → EQUIPMENT.EQUIPMENT_ID
-- no invalid equipmentIds
SELECT *
FROM MONEQUIP.SALES
WHERE EQUIPMENT_ID NOT IN (
    SELECT EQUIPMENT_ID FROM MONEQUIP.EQUIPMENT
);
-- check for null values
-- no null values
SELECT *
FROM MONEQUIP.SALES
WHERE EQUIPMENT_ID IS NULL;


-- checking SALES.STAFF_ID → STAFF.STAFF_ID
-- no invalid staffId
SELECT *
FROM MONEQUIP.SALES
WHERE STAFF_ID NOT IN (
    SELECT STAFF_ID FROM MONEQUIP.STAFF
);
-- no null values
SELECT *
FROM MONEQUIP.SALES
WHERE STAFF_ID IS NULL;

-- checking HIRE.EQUIPMENT_ID → EQUIPMENT.EQUIPMENT_ID
SELECT *
FROM MONEQUIP.HIRE
WHERE EQUIPMENT_ID NOT IN (
    SELECT EQUIPMENT_ID FROM MONEQUIP.EQUIPMENT
);
-- updated table
UPDATE new_hire
SET EQUIPMENT_ID = NULL
WHERE EQUIPMENT_ID NOT IN (
    SELECT EQUIPMENT_ID FROM MONEQUIP.EQUIPMENT
);
SELECT * FROM new_hire;
-- no null values
SELECT *
FROM MONEQUIP.HIRE
WHERE EQUIPMENT_ID IS NULL;


-- checking HIRE.CUSTOMER_ID → CUSTOMER.CUSTOMER_ID
-- no invalid customer IDs
SELECT *
FROM MONEQUIP.HIRE
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID FROM MONEQUIP.CUSTOMER
);
-- no null values
SELECT *
FROM MONEQUIP.HIRE
WHERE CUSTOMER_ID IS NULL;


-- checking HIRE.STAFF_ID → STAFF.STAFF_ID
SELECT *
FROM MONEQUIP.HIRE
WHERE STAFF_ID NOT IN (
    SELECT STAFF_ID FROM MONEQUIP.STAFF
);
-- updating staff_id to null 
UPDATE new_hire
SET STAFF_ID = NULL
WHERE STAFF_ID NOT IN (
    SELECT STAFF_ID FROM MONEQUIP.STAFF
);
SELECT * FROM new_hire;
-- no null values
SELECT *
FROM MONEQUIP.HIRE
WHERE STAFF_ID IS NULL;


-- checking sales table
-- valid equipment IDs
SELECT *
FROM MONEQUIP.SALES 
WHERE EQUIPMENT_ID  NOT IN (
    SELECT EQUIPMENT_ID FROM MONEQUIP.EQUIPMENT
);
-- valid customer Ids
SELECT *
FROM MONEQUIP.SALES 
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID FROM MONEQUIP.CUSTOMER
);
-- valid customer Ids
SELECT *
FROM MONEQUIP.SALES 
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID FROM MONEQUIP.CUSTOMER
);
-- valid staff Ids
SELECT *
FROM MONEQUIP.SALES 
WHERE STAFF_ID NOT IN (
    SELECT STAFF_ID FROM MONEQUIP.staff
);

SELECT * FROM MONEQUIP.SALES s 


-- finding inconsistencies
-- checking date in hire table where end date is earlier than the start date
-- finding which entries have problems with the date
SELECT HIRE_ID,
       START_DATE,
       END_DATE
FROM MONEQUIP.HIRE h 
WHERE END_DATE < START_DATE;

-- updating hire table to and swapping these values
UPDATE new_hire
SET START_DATE = END_DATE,
    END_DATE = START_DATE
WHERE END_DATE < START_DATE;

-- checking if changes worked
SELECT * FROM new_hire;


-- updating 'null' description to something which provides more of a description
UPDATE new_category
SET category_description = 'Miscellaneous'
WHERE category_description = 'null';

SELECT * FROM NEW_CATEGORY nc; 

-- updating any null values in customer table
UPDATE new_customer
SET customer_id = (SELECT MAX(customer_id) + 1 FROM new_customer)
WHERE customer_id IS NULL;

SELECT * FROM NEW_CUSTOMER nc;

-- checking if theres negative values in quantity under sales table
SELECT *
FROM MONEQUIP.sales
WHERE quantity < 0;

UPDATE new_sales
SET quantity = ABS(quantity)
WHERE quantity < 0;

-- checking where total_sales_price doesn't match expected calculation
SELECT sales_id,
       sales_date,
       equipment_id,
       quantity,
       unit_sales_price,
       total_sales_price
FROM MONEQUIP.SALES s 
WHERE total_sales_price <> (quantity * unit_sales_price);
-- updating calculation
UPDATE new_sales
SET total_sales_price = quantity * unit_sales_price
WHERE total_sales_price <> (quantity * unit_sales_price);

select * FROM new_sales WHERE sales_id = 151;
-- getting rid of entries which isn't between 2018-2020

SELECT * FROM MONEQUIP.HIRE h 
WHERE start_date < DATE '2018-04-01'
   OR start_date > DATE '2020-12-31';
DELETE FROM new_hire
WHERE start_date < DATE '2018-04-01'
   OR start_date > DATE '2020-12-31';
SELECT * FROM new_hire WHERE hire_id >300;

DELETE FROM new_sales
WHERE sales_date < DATE '2018-04-01'
   OR sales_date > DATE '2020-12-31';
-- updating calculation for total_hire_price
SELECT 
    h.hire_id,
    h.start_date,
    h.end_date,
    h.quantity,
    h.unit_hire_price,
    h.total_hire_price,
    CASE 
        WHEN DATEDIFF(DAY, h.start_date, h.end_date) = 0 
             THEN 0.5 * h.unit_hire_price * h.quantity
        ELSE (DATEDIFF(DAY, h.start_date, h.end_date) * h.unit_hire_price * h.quantity)
    END AS expected_total
FROM MONEQUIP.HIRE h
WHERE h.total_hire_price <>
      CASE 
        WHEN DATEDIFF(DAY, h.start_date, h.end_date) = 0 
             THEN 0.5 * h.unit_hire_price * h.quantity
        ELSE (DATEDIFF(DAY, h.start_date, h.end_date) * h.unit_hire_price * h.quantity)
      END;



-- implememting star/snowflake schema
DROP TABLE DimBranch;
CREATE TABLE DimBranch (
    Branch_ID        VARCHAR2(10),
    BranchName       VARCHAR2(50)
);
-- Populate with distinct branches from STAFF table company_branch
INSERT INTO DimBranch (Branch_ID, BranchName)
SELECT 'B' || ROWNUM, COMPANY_BRANCH
FROM (SELECT DISTINCT COMPANY_BRANCH FROM new_STAFF);

SELECT * FROM DIMBRANCH d ;


DROP TABLE DimMonth;
CREATE TABLE DimMonth (
    Month_ID   VARCHAR2(10),
    MonthName  VARCHAR2(10)
);

INSERT INTO DimMonth VALUES ('M01', 'Jan');
INSERT INTO DimMonth VALUES ('M02', 'Feb');
INSERT INTO DimMonth VALUES ('M03', 'Mar');
INSERT INTO DimMonth VALUES ('M04', 'Apr');
INSERT INTO DimMonth VALUES ('M05', 'May');
INSERT INTO DimMonth VALUES ('M06', 'Jun');
INSERT INTO DimMonth VALUES ('M07', 'Jul');
INSERT INTO DimMonth VALUES ('M08', 'Aug');
INSERT INTO DimMonth VALUES ('M09', 'Sep');
INSERT INTO DimMonth VALUES ('M10', 'Oct');
INSERT INTO DimMonth VALUES ('M11', 'Nov');
INSERT INTO DimMonth VALUES ('M12', 'Dec');
SELECT * FROM dimmonth;


DROP TABLE DimYear;
CREATE TABLE DimYear (
    Year_ID  VARCHAR2(10),
    YearVal  NUMBER
);

INSERT INTO DimYear (Year_ID, YearVal)
SELECT 'Y' || ROWNUM, YearVal
FROM (
    SELECT DISTINCT TO_NUMBER(TO_CHAR(SALES_DATE,'YYYY')) AS YearVal FROM NEW_SALES
    UNION
    SELECT DISTINCT TO_NUMBER(TO_CHAR(START_DATE,'YYYY')) FROM new_hire
)
ORDER BY YearVal;
SELECT * FROM dimyear;


DROP TABLE DimSeason;
CREATE TABLE DimSeason (
    Season_ID   VARCHAR2(10),
    SeasonDescription  VARCHAR2(20)
);
INSERT INTO DimSeason VALUES ('S1', 'Summer');   -- Dec, Jan, Feb
INSERT INTO DimSeason VALUES ('S2', 'Autumn');   -- Mar, Apr, May
INSERT INTO DimSeason VALUES ('S3', 'Winter');   -- Jun, Jul, Aug
INSERT INTO DimSeason VALUES ('S4', 'Spring');   -- Sep, Oct, Nov
SELECT * FROM DimSeason;

DROP TABLE CustomerDim;
CREATE TABLE CustomerDim 
AS SELECT customer_id, name, gender, customer_type_id FROM new_customer;
SELECT * FROM customerdim;

DROP TABLE Dim_customer_type;
CREATE TABLE Dim_customer_type
AS SELECT * FROM new_customer_type;

DROP TABLE DimEquipment;
CREATE TABLE DimEquipment
AS SELECT * FROM new_equipment;

DROP TABLE DimCategory;
CREATE TABLE DimCategory
AS SELECT * FROM new_category;

DROP TABLE DimSalesPriceScale;
CREATE TABLE DimSalesPriceScale (
	SalesPriceScale_ID	VARCHAR2(10),
	Scale	VARCHAR2(20)
);
INSERT INTO DimSalesPriceScale VALUES ('PS1','Low Sales');
INSERT INTO DimSalesPriceScale VALUES ('PS2','Medium Sales');
INSERT INTO DimSalesPriceScale VALUES ('PS3','High Sales');
SELECT * FROM DimSalesPriceScale;


DROP TABLE tempfact_sales;
CREATE TABLE tempfact_sales AS
SELECT distinct S.sales_id, C.customer_ID, E.equipment_ID, S.unit_sales_price, S.sales_date, S.quantity, S.total_sales_price, SF.staff_ID
FROM new_sales S, new_equipment E, new_customer C, new_staff SF
WHERE S.customer_ID = C.customer_id
AND S.equipment_ID = E.equipment_ID
AND S.staff_ID = SF.staff_ID;
SELECT * FROM tempfact_sales;

-- updating tempfact_sales with branch
ALTER TABLE tempfact_sales
ADD(Branch_ID varchar2(10));

UPDATE tempfact_sales t
SET Branch_ID = (
    SELECT d.Branch_ID
    FROM DimBranch d
    JOIN new_staff s 
      ON d.BranchName = s.company_branch
    WHERE s.staff_ID = t.staff_ID
);
-- updating tempfact_sales with month
ALTER TABLE TEMPFACT_SALES
ADD (Month_ID VARCHAR2(10));

UPDATE tempfact_sales
SET Month_ID = 'M' || TO_CHAR(sales_date, 'MM');
--updating tempfact_sales with year
ALTER TABLE tempfact_sales
ADD (year_ID varchar2(10));


UPDATE tempfact_sales
SET Year_ID = 'Y1'
WHERE TO_NUMBER(TO_CHAR(sales_date,'yyyy')) = 2018;
UPDATE tempfact_sales
SET Year_ID = 'Y2'
WHERE TO_NUMBER(TO_CHAR(sales_date,'yyyy')) = 2019;
UPDATE tempfact_sales
SET Year_ID = 'Y3'
WHERE TO_NUMBER(TO_CHAR(sales_date,'yyyy')) = 2020;
SELECT * FROM tempfact_sales;
--updating tempfact_sales with season
ALTER TABLE TEMPFACT_SALES
add(season_ID varchar2(10));

UPDATE tempfact_sales
SET season_ID = 'S1'
WHERE TO_NUMBER(TO_CHAR(sales_date,'MM')) >= 12 or TO_NUMBER(TO_CHAR(sales_date,'MM')) <= 2;
UPDATE tempfact_sales
SET season_ID = 'S2'
WHERE TO_NUMBER(TO_CHAR(sales_date,'MM')) >= 3 and TO_NUMBER(TO_CHAR(sales_date,'MM')) <= 5;
UPDATE tempfact_sales
SET season_ID = 'S3'
WHERE TO_NUMBER(TO_CHAR(sales_date,'MM')) >= 6 and TO_NUMBER(TO_CHAR(sales_date,'MM')) <= 8;
UPDATE tempfact_sales
SET season_ID = 'S4'
WHERE TO_NUMBER(TO_CHAR(sales_date,'MM')) >= 9 and TO_NUMBER(TO_CHAR(sales_date,'MM')) <= 11;
--updating sales price scale 
ALTER TABLE tempfact_sales
ADD (SalesPriceScale_ID VARCHAR2(10));

-- Low Sales: <$5000
UPDATE tempfact_sales
SET SalesPriceScale_ID = 'PS1'
WHERE total_sales_price < 5000;

-- Medium Sales: $5000–$10000
UPDATE tempfact_sales
SET SalesPriceScale_ID = 'PS2'
WHERE total_sales_price >= 5000
  AND total_sales_price <= 10000;

-- High Sales: >$10000
UPDATE tempfact_sales
SET SalesPriceScale_ID = 'PS3'
WHERE total_sales_price > 10000;

SELECT * FROM tempfact_sales;
-- creating fact_sales table
DROP TABLE fact_sales;
CREATE TABLE fact_sales as
SELECT t.Sales_ID, t.Month_ID, t.year_ID, t.Season_ID, t.Customer_ID, t.Equipment_ID, t.Branch_ID, t.SalesPriceScale_ID, t.Unit_Sales_Price,
sum(t.total_sales_price) AS total_sales_revenue, sum(t.quantity) AS quantity_sold
FROM tempfact_sales t
GROUP BY t.Sales_ID, t.Month_ID, t.year_ID, t.Season_ID, t.Customer_ID, t.Equipment_ID, t.Branch_ID, t.SalesPriceScale_ID, t.Unit_Sales_Price;
SELECT * FROM fact_sales;

--creating tempfact_hire
DROP TABLE tempfact_hire;
CREATE TABLE tempfact_hire AS
SELECT distinct H.hire_id, C.customer_ID, E.equipment_ID, H.unit_hire_price, H.start_date, H.quantity, H.total_hire_price, SF.staff_ID
FROM new_hire H, new_equipment E, new_customer C, new_staff SF
WHERE H.customer_ID = C.customer_id
AND H.equipment_ID = E.equipment_ID
AND H.staff_ID = SF.staff_ID;

-- updating tempfact_hire with branch
ALTER TABLE tempfact_hire
ADD(Branch_ID varchar2(10));

UPDATE tempfact_hire t
SET Branch_ID = (
    SELECT d.Branch_ID
    FROM DimBranch d
    JOIN new_staff s 
      ON d.BranchName = s.company_branch
    WHERE s.staff_ID = t.staff_ID
);
-- updating tempfact_sales with month
ALTER TABLE TEMPFACT_hire
ADD (Month_ID VARCHAR2(10));

UPDATE tempfact_hire
SET Month_ID = 'M' || TO_CHAR(start_date, 'MM');
--updating tempfact_sales with year
ALTER TABLE tempfact_hire
ADD (year_ID varchar2(10));


UPDATE tempfact_hire
SET Year_ID = 'Y1'
WHERE TO_NUMBER(TO_CHAR(start_date,'yyyy')) = 2018;
UPDATE tempfact_hire
SET Year_ID = 'Y2'
WHERE TO_NUMBER(TO_CHAR(start_date,'yyyy')) = 2019;
UPDATE tempfact_hire
SET Year_ID = 'Y3'
WHERE TO_NUMBER(TO_CHAR(start_date,'yyyy')) = 2020;
--updating tempfact_sales with season
ALTER TABLE TEMPFACT_hire
add(season_ID varchar2(10));

UPDATE tempfact_hire
SET season_ID = 'S1'
WHERE TO_NUMBER(TO_CHAR(start_date,'MM')) >= 12 or TO_NUMBER(TO_CHAR(start_date,'MM')) <= 2;
UPDATE tempfact_hire
SET season_ID = 'S2'
WHERE TO_NUMBER(TO_CHAR(start_date,'MM')) >= 3 and TO_NUMBER(TO_CHAR(start_date,'MM')) <= 5;
UPDATE tempfact_hire
SET season_ID = 'S3'
WHERE TO_NUMBER(TO_CHAR(start_date,'MM')) >= 6 and TO_NUMBER(TO_CHAR(start_date,'MM')) <= 8;
UPDATE tempfact_hire
SET season_ID = 'S4'
WHERE TO_NUMBER(TO_CHAR(start_date,'MM')) >= 9 and TO_NUMBER(TO_CHAR(start_date,'MM')) <= 11;

SELECT * FROM tempfact_hire;

-- creating fact_hire table
DROP TABLE fact_hire;
CREATE TABLE fact_hire as
SELECT t.hire_ID, t.Month_ID, t.year_ID, t.Season_ID, t.Customer_ID, t.Equipment_ID, t.Branch_ID, t.Unit_hire_Price,
sum(t.total_hire_price) AS total_hire_revenue, sum(t.quantity) AS quantity_hired
FROM tempfact_hire t
GROUP BY t.hire_ID, t.Month_ID, t.year_ID, t.Season_ID, t.Customer_ID, t.Equipment_ID, t.Branch_ID, t.Unit_hire_Price;
SELECT * FROM fact_hire;

--example queries
SELECT 
    AVG(f.total_sales_revenue) AS avg_lighting_revenue_2019
FROM fact_sales f
JOIN DimYear y 
    ON f.Year_ID = y.Year_ID
JOIN DIMEQUIPMENT e
    ON f.Equipment_ID = e.Equipment_ID
JOIN Dimcategory c
    ON e.Category_ID = c.Category_ID
WHERE y.YearVal = 2019
  AND c.Category_Description = 'Lighting';

SELECT SUM(fs.total_sales_revenue) AS total_sales_revenue_jan_2020
FROM fact_sales fs
JOIN DimMonth dm   ON fs.Month_ID = dm.Month_ID
JOIN DimYear dy    ON fs.Year_ID = dy.Year_ID
WHERE dm.MonthName = 'Jan'
  AND dy.YearVal   = 2020;

SELECT SUM(fs.quantity_sold) AS total_equipment_sold_winter_2018
FROM fact_sales fs
JOIN DimSeason ds ON fs.Season_ID = ds.Season_ID
JOIN DimYear dy   ON fs.Year_ID   = dy.Year_ID
WHERE ds.SeasonDescription = 'Winter'
  AND dy.YearVal = 2018;

SELECT SUM(h.quantity_hired) AS total_equipment_hired_business_customers
FROM fact_hire h
JOIN CustomerDim c ON h.customer_id = c.customer_id
WHERE c.customer_type_id IN (
  SELECT customer_type_id FROM Dim_customer_type WHERE UPPER(description) LIKE '%BUSINESS%'
);

SELECT SUM(fh.total_hire_revenue) AS total_hire_revenue_clayton
FROM fact_hire fh
JOIN DimBranch db ON fh.Branch_ID = db.Branch_ID
WHERE db.BranchName = 'Clayton';

SELECT SUM(fh.quantity_hired) AS total_trailers_hired
FROM fact_hire fh
JOIN CustomerDim c   ON fh.customer_id = c.customer_id
JOIN DimEquipment e  ON fh.equipment_id = e.equipment_id
JOIN DimCategory cat ON e.category_id   = cat.category_id    -- join to category
JOIN DimSeason ds    ON fh.Season_ID    = ds.Season_ID
WHERE ds.SeasonDescription = 'Summer'
  AND c.customer_type_id IN (
    SELECT customer_type_id
    FROM Dim_customer_type
    WHERE UPPER(description) LIKE '%INDIVIDUAL%'
  )
  AND UPPER(cat.category_description) LIKE '%TRAILER%';



SELECT AVG(fh.total_hire_revenue) AS avg_hire_revenue_vehicles_individual
FROM fact_hire fh
JOIN CustomerDim c   ON fh.customer_id = c.customer_id
JOIN DimEquipment e  ON fh.equipment_id = e.equipment_id
JOIN DimCategory cat ON e.category_id   = cat.category_id    -- join to category
WHERE c.customer_type_id IN (
    SELECT customer_type_id
    FROM Dim_customer_type
    WHERE UPPER(description) LIKE '%INDIVIDUAL%'
)
AND UPPER(cat.category_description) LIKE '%VEHICLE%';


SELECT AVG(total_sales_revenue) AS avg_sales_revenue
FROM fact_sales;














