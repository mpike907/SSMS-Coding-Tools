
/* INTRO to JOINS, GROUP BY, and ORDER BY! 
   Written by M.Pike 2/14/2023 

This code was written to assist newcomers to SSMS who need to perform queries
within databases and tables within databases
This is code that will help with joins, grouping & ordering. 

What types of JOINS do we have?
- Inner join
- Left outer join
- Right outer join
- Full outer join
- Cross join

By using joins, you can retrieve data from two or more tables based on logical 
relationships between the tables. Joins indicate how SQL Server should use 
data from one table to select the rows in another table.

This code will focus on code for LEFT JOINS, since we usually do these joins 
when we are joining tables during epidemiological data analysis.

LEFT JOINS returns ALL records from the left table (table 1), and the matching 
records from the right table (table2). The result is 0 records from the right 
side, if there is no match. 

This is the syntax: */; 

SELECT column_name(s)
FROM table1
LEFT JOIN table2
ON table1.column_name = table2.column_name;


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
/* GROUP BY

The GROUP BY statement groups rows that have the same values 
into summary rows, like "find the number of cases in each county".

The GROUP BY statement is often used with aggregate functions 
(COUNT(), MAX(), MIN(), SUM(), AVG()) to group the result-set by 
one or more columns.

This is the syntax: */; 

SELECT column_name(s)
FROM table_name
WHERE condition
GROUP BY column_name(s)
ORDER BY column_name(s); 

/* This gives all the counts by eventid by countyassigned in CO */;
SELECT	COUNT(EventId), 
		countyassigned
	FROM [covid19].[dbo].[cedrs_view] 
	GROUP BY countyassigned;

/**************************************************************/
/* ORDER BY

The ORDER BY keyword is used to sort the result-set in ascending 
or descending order. The ORDER BY keyword sorts the records in 
ascending order by default. To sort the records in descending order, 
use the DESC keyword. */

SELECT *  /* use the * when we want to select ALL variables */
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE breakthrough = 1
	ORDER BY countyassigned;

SELECT	eventid,
	    collectiondate,
		breakthrough
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE breakthrough = 1 and collectiondate >= '2023-01-05'
	ORDER BY countyassigned;


SELECT *  
	FROM [covid19].[dbo].[cedrs_view] 
	WHERE breakthrough = 1
	ORDER BY countyassigned DESC;

/* END OF CODE */