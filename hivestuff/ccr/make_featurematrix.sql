--creating the GFR table
drop table if exists tab_gfr_temp;
CREATE TABLE tab_gfr_temp (idperson STRING, rDate STRING,gender STRING, year STRING, age STRING, gfr STRING, gfrStan STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath 'hdfs:///hivedata/cdr_gfr_derived.csv' into table tab_gfr_temp;

--creating the Lab table
drop table if exists tab_lab_temp;
CREATE TABLE tab_lab_temp (labid STRING, idData STRING,idperson STRING, testName STRING, statusId STRING, laborderId STRING, testNameStr STRING,
encountId STRING, rDate STRING, fasting STRING, rVal STRING, rValStr STRING , rValUnit STRING,rValNormRan STRING,rValCode STRING,
labperformedby STRING,labtype STRING,labreasoncode STRING,labreasonrelated STRING,dateadded STRING,dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

load data local inpath 'hdfs:///hivedata/cdr_lab_result.csv' into table tab_lab_temp;

--creating the findings table
drop table if exists tab_finding_temp;
CREATE TABLE tab_finding_temp (findingId STRING,iddatasrcdtl STRING, testName STRING, idperson STRING, idstatus STRING, idencounter STRING,idprovider STRING, srcvaluestr STRING, rVal STRING, findvalstr STRING, findvalum STRING, rDate STRING, findordinal STRING, dateadded STRING, dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath 'hdfs:///hivedata/cdr_finding.csv' into table tab_finding_temp;

--creating the social_history table
drop table if exists tab_history_social_temp;
CREATE TABLE tab_history_social_temp (idsocial STRING, iddatasrcdtl STRING, idperson STRING, idstatus STRING, valuename STRING, srcvaluestr STRING, idencounter STRING, socdate STRING, socordinal STRING, socstatusitem STRING, socstatussrc STRING, socprovinitial STRING, socprovinitialdesc STRING, socprovlastaddressed STRING, socprovlastaddresseddesc STRING, socaction STRING, socplan STRING, dateadded STRING, dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath 'hdfs:///hivedata/cdr_history_social.csv' into table tab_history_social_temp;


---- ====== Remove the time part from the timestamp for each table, and selecting only relevant columns ====== ----

--removing the time from the date in the GFR table.
drop table if exists tab_gfr;
CREATE TABLE tab_gfr as select idperson ,substr(rDate,0,10) as rDate ,gender,year,age,gfrStan from tab_gfr_temp;


--removing the time from the date in the lab table.
drop table if exists tab_lab;
CREATE TABLE tab_lab as select idperson,substr(rDate,0,10) as rDate, testName, rVal from tab_lab_temp;


--removing the time from the date in the findings table.
drop table if exists tab_finding;
CREATE TABLE tab_finding as select idperson,substr(rDate,0,10) as rDate,testName,rVal from tab_finding_temp;


--removing the time from the date in the findings table.
drop table if exists tab_history_social;
CREATE TABLE tab_history_social as 
	SELECT idperson, MAX(valuename) as smokercategory, MAX(srcvaluestr) as smokerdetail 
	FROM tab_history_social_temp
	WHERE idperson IS NOT NULL and valuename IS NOT NULL
	GROUP BY idperson;



--joining the three tables and generating the final result
drop table if exists tab_final;
CREATE TABLE tab_final as
select t1.idperson,t1.rDate,t1.gender,t1.year,t1.age, t4.smokercategory, t4.smokerdetail,
t2.testName as lab_test,t2.rVal as lab_test_val,
t3.testName as finding_testname,t3.rVal as finding_test_val, 
t1.gfrStan
from tab_gfr t1, tab_lab t2, tab_finding t3, tab_history_social t4
where t1.idperson=t2.idperson and t1.rDate=t2.rDate and t1.idperson=t3.idperson and t1.rDate=t3.rDate
and t1.idperson=t4.idperson;


select * from tab_final LIMIT 10;
--run this from the terminal
-- hive -e 'select * from tab_final' > /home/castamere/code/independent/outputs/hive_results.csv