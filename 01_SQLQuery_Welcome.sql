
/* WELCOME TO SSMS! 
Written by M.Pike 2/14/2023
This code was written to assist newcomers to SSMS who need to perform queries
within databases and tables within databases. SSMS allows you to access, 
configure, manage, administer, and develop all components of SQL Server. 
If you're using SSMS, you will need admin rights in order to create tables.
However, you still can use SSMS to query questions you have about the data
on the server. This will help you get started with SSMS.

/* Connect to a SQL Server
You should get a prompt when opening to connect to a SQL Server. If not, 
this will help you connect and view databases on that server */;

(1) In Management Studio, on FILE menu select CONNECT OBJECT EXPLORER. 
(2) The CONNECT TO SERVER dialog box will open. The SERVER TYPE box displays the type of
	component that was last used.
(3) Select DATABASE ENGINE. 
(4) In the "Server name" select the name of the Database Engine. This might be in a drop down box. 
	If this is not available, you may have to go into ODBC DATA SOURCES on your computer, set up 
	server connections, utilizing admin approval (if needed to access certain connections). */

/**************************************************************/	
/* Find a COUNTS for a variable (Similiar to a PROC FREQ in SAS) */
/* How many eventids (cases) are there were breakthrough = 1? */;

SELECT COUNT (eventid) 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE Breakthrough = 1; 

/* How many eventids (cases) are there were breakthrough = 1 on & after 9/1/2022? */;	
SELECT COUNT (eventid) 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE Breakthrough = 1 and collectiondate >= '2022-09-01' 

/* How many eventids (cases) are there were breakthrough = 1 and hospitialized in September 2022? */;	
/* use BETWEEN, as it is similar to >= and <= */
SELECT COUNT (eventid) 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE Breakthrough = 1 and hospitalized = 1 and collectiondate between '2022-09-01' and '2022-09-30' 

/* How many cases in people age 50+ occurred on or after Sept 1, 2022?*/
SELECT COUNT (eventid) 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE age_at_reported >= 50 and collectiondate between '2022-09-01' and '2022-09-30' 


/**************************************************************/
/* SELECT DATA (Similar to a PROC SQL or DATA step in SAS) */
/* Select all rows where CollectionDates on or after 9/1/2022. */
SELECT * 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE collectiondate >= '2022-09-01'

/* Select all rows on several variables and CollectionDates between 9/1/2022 and 9/30/2022. */
SELECT * 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE reinfection = 1 and breakthrough = 1 and collectiondate between '2022-09-01' and '2022-09-30'

/* Select rows (cases) in a specific county with collection dates on or after 9/1/2022. */
SELECT * 
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE countyassigned = 'MESA' and breakthrough = 1 and collectiondate between '2022-09-01' and '2022-09-30'


/**************************************************************/
/* How to SUM / Cumulative  */

/* How many people who are 40-49 received a bivalent vaccination on a specific date?*/
/* For this, you'll need to get a cumulative sum of those 40-49 who have a bivalent dose on a specific date */
/* First, pull all those cases you need between 40-49 */
SELECT	age, 
	total_bivalent
	FROM [covid19].[ciis].[vaxunvax_age_bivalent] 
	WHERE age between 40 and 49 and date = '2022-12-15'

/*Second, do a cumulative sum and check your work to the first data pull */
SELECT	age, 
	SUM(total_bivalent) over (order by age) Cumulative_total
	FROM [covid19].[ciis].[vaxunvax_age_bivalent] 
	WHERE age between 40 and 49 and date = '2022-12-15'
/* cumulative_total for 40-49 will output on age = 49 */
/* check that sum of first and second outputs are equal */


/**************************************************************/
/* LEFT JOIN EXAMPLES: */
/* IMMUNIZATION DATA */
/* Pull immunization data from cases_iz & match to CEDRS */
/* Grabs vaccination data from CIIS and matches to cases in CEDRS */

SELECT iz.profileid, iz.eventid, iz.vaccination_date, iz.vaccination_code_id, 
		cdr.profileid, cdr.eventid,cdr.collectiondate, cdr.countyassigned, cdr.breakthrough,
			 cdr.partialonly, cdr.reinfection, cdr.hospitalized, cdr.deathdueto_vs_u071

	FROM [covid19].[ciis].[case_iz] iz
	
	LEFT JOIN [covid19].[dbo].[cedrs_view] cdr on iz.eventid = cdr.eventid
	
	WHERE BREAKTHROUGH = 1 
	ORDER BY iz.eventid, iz.vaccination_date
; 

/**************************************************************/
/* ELR DATA PULLS */;
/* This code creates a trailing 3-week variable based upon when lab last submitted */

WITH raw_data ( PatientID,Test_LOINC, CollectionDate, ReceiveDate, Submitter, Result, DateAdded, ResultDate, Sender, 
Performing_Organization, COVID19Negative, sender_new ) AS (

SELECT
PatientID
, Test_LOINC
, CollectionDate
, ReceiveDate
, Submitter
, Result
, DateAdded
, ResultDate
, Sender
, Performing_Organization
, COVID19Negative
, CASE WHEN sender = 'ProviderFlatfileUpload' or sender is null THEN submitter ELSE sender end as sender_new

from ELR_DW.dbo.viewPatientTestELR

where
CollectionDate > '2022-11-10' and
Test_LOINC in  ('41458-1', '94306-8', '94309-2', '94500-6', '94502-2', '94531-1', '94533-7', 
                '94534-5', '94559-2', '94565-9', '94568-9', '94640-0', '94756-4', '94757-2', 
                '94759-8', '94760-6', '94845-5', '95406-5', '95409-9', '95423-0', '95425-5', 
                '95608-6', '96094-8', '96123-5', '96448-6', '96986-5', '99999-9', 'COV19RES', 
                'COVID', 'Z5664', 'COV_CHLDRN', 'UN_COV_RT', 'COVIDEPLEX', '2019-nCoV RNA')
), sender_daily_totals ( DateAdded, daily_total, sender_new )  as (

SELECT
DateAdded
, count(*) as daily_total
, sender_new
FROM raw_data
group by DateAdded, sender_new

)

SELECT
*
, sum(daily_total) OVER ( PARTITION BY sender_new ORDER BY DateAdded ROWS 2 PRECEDING ) AS trailing3_results
FROM sender_daily_totals
