drop table if exists tab_gfr;
CREATE TABLE tab_gfr (pId STRING, rDate STRING,gender STRING, year STRING, age STRING, gfr STRING, gfrStan STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath '/home/castamere/code/independent/pigscripts/smalldatasets/small_cdr_gfr_derived.csv' into table tab_gfr;

drop table if exists tab_lab;
CREATE TABLE tab_lab (labid STRING, idData STRING,pId STRING, testName STRING, statusId STRING, laborderId STRING, testNameStr STRING,
encountId STRING, rDate STRING, fasting STRING, rVal STRING, rValStr STRING , rValUnit STRING,rValNormRan STRING,rValCode STRING,
labperformedby STRING,labtype STRING,labreasoncode STRING,labreasonrelated STRING,dateadded STRING,dateupdated STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
load data local inpath '/home/castamere/code/independent/pigscripts/smalldatasets/cdr_finding.csv' into table tab_lab;

create table tab_lab_small as 
select pId,testName,rDate,rVal from tab_lab;