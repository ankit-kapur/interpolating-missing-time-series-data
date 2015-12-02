REGISTER pigjars/pig.jar;
REGISTER pigjars/piggybank.jar;

------- Load the eGFR data
-- raw_data = LOAD 'hdfs:///pigdata/' USING PigStorage(',','-tagFile');
egfr_data = LOAD 'smalldatasets/small_cdr_gfr_derived.csv' USING PigStorage(',');

egfr_data = FOREACH egfr_data GENERATE $0 as idperson, $1 as datetimestamp, $2 as gender, $3 as birthyear, $4 as age, (DOUBLE)$6 as gfr;

------- Filter out the headers
egfr_data = FILTER egfr_data BY idperson neq 'idperson';

------- Get identifier using UDF
time_removed = FOREACH egfr_data {
			timestamp = SUBSTRING((chararray)datetimestamp,0,10);
			GENERATE idperson, timestamp, gender, birthyear, age, gfr;
		}


------ Store the results
-- STORE result INTO 'hdfs:///pigdata/out_folder';
STORE time_removed INTO 'out_folder';
