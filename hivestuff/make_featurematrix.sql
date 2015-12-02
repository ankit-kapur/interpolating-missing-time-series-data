--creating the GFR table
drop table if exists tab_gfr_temp;
CREATE TABLE tab_gfr_temp (pId STRING, rDate STRING,gender STRING, year STRING, age STRING, gfr STRING, gfrStan STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath '/home/castamere/code/independent/datasets/cdr_gfr_derived.csv' into table tab_gfr_temp;

--creating the Lab table
drop table if exists tab_lab_temp;
CREATE TABLE tab_lab_temp (labid STRING, idData STRING,pId STRING, testName STRING, statusId STRING, laborderId STRING, testNameStr STRING,
encountId STRING, rDate STRING, fasting STRING, rVal STRING, rValStr STRING , rValUnit STRING,rValNormRan STRING,rValCode STRING,
labperformedby STRING,labtype STRING,labreasoncode STRING,labreasonrelated STRING,dateadded STRING,dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

load data local inpath '/home/castamere/code/independent/datasets/cdr_lab_result.csv' into table tab_lab_temp;

--creating the findings table
drop table if exists tab_finding_temp;
CREATE TABLE tab_finding_temp (findingId STRING,iddatasrcdtl STRING, testName STRING,pId STRING,idstatus STRING,idencounter STRING,idprovider STRING,srcvaluestr STRING, rVal STRING, findvalstr STRING, findvalum STRING, rDate STRING, findordinal STRING, dateadded STRING, dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath '/home/castamere/code/independent/datasets/cdr_finding.csv' into table tab_finding_temp;




--removing the time from the date in the GFR table.
drop table if exists tab_gfr;
CREATE TABLE tab_gfr as select t1.pId ,substr(t1.rDate,0,10) as rDate ,t1.gender,t1.year,t1.age,t1.gfrStan from tab_gfr_temp t1;


--removing the time from the date in the lab table.
drop table if exists tab_lab;
CREATE TABLE tab_lab as select t2.pId,substr(t2.rDate,0,10) as rDate,t2.testName, t2.rVal from tab_lab_temp t2;


--removing the time from the date in the findings table.
drop table if exists tab_finding;
CREATE TABLE tab_finding as select t3.pId,substr(t3.rDate,0,10) as rDate,t3.testName,t3.rVal from tab_finding_temp t3;


--joining the three tables and generating the final result
drop table if exists tab_lab_gfr_fin;
drop table if exists tab_final;
CREATE TABLE tab_final as
select t1.pId,t1.rDate,t1.gender,t1.year,t1.age,
t2.testName as lab_test,t2.rVal as lab_test_val,
t3.testName as finding_testname,t3.rVal as finding_test_val, 
t1.gfrStan
from tab_gfr t1, tab_lab t2, tab_finding t3 where t1.pId=t2.pId and t1.rDate=t2.rDate and t1.pId=t3.pId and t1.rDate=t3.rDate;


--run this from the terminal
-- hive -e 'select * from tab_final' > /home/castamere/code/independent/hivestuff/hive_results.csv