REGISTER piggybank.jar;
REGISTER udf_ankit.jar;

------- Load the raw data
raw_data = LOAD 'hdfs:///pigdata/' USING PigStorage(',','-tagFile');

raw_data = FOREACH raw_data GENERATE $0 as filename, $1 as date, (DOUBLE)$7 as adjClose;

------- Filter out the headers
filtered_data = FILTER raw_data BY date neq 'Date';

------- Get identifier using UDF
processed_data = FOREACH filtered_data {
			ym = SUBSTRING((chararray)date,0,7);
			dayOfTheMonth = (INT)(SUBSTRING((chararray)date,8,10));
			GENERATE filename, ym as yearMonth, dayOfTheMonth as day, adjClose;
		 }

------- Group stockname & year-month
grouped_data = GROUP processed_data BY (filename, yearMonth);

------- Find the first (MIN) and last (MAX) days of each month
minmax = FOREACH grouped_data {
		asc_sorted = ORDER processed_data BY day;
		desc_sorted = ORDER processed_data BY day DESC;
		min_row = LIMIT asc_sorted 1;
		max_row = LIMIT desc_sorted 1;
		GENERATE FLATTEN(min_row.filename) as filename, FLATTEN(min_row.yearMonth) as yearMonth,
				 FLATTEN(min_row.adjClose) as minAdj, FLATTEN(max_row.adjClose) as maxAdj;
          }

------- Generate Xi
with_xi = FOREACH minmax GENERATE filename, yearMonth, ((minAdj != 0.0) ? ((maxAdj - minAdj)/minAdj) : 0.0) as xi;

------- Calculate x_bar
grouped_stocks = GROUP with_xi BY filename;
with_xbar = FOREACH grouped_stocks {
		summation = SUM(with_xi.xi);
		count = COUNT(with_xi.xi);
		xbarVal = (count>0 ? (DOUBLE)(summation/count) : 0.0);
		GENERATE group as stock_name, count as N, with_xi.xi as xi, xbarVal as xbar;
	}

------- Get the volatility!
volatility = FOREACH with_xbar GENERATE stock_name, ankit.CalculateVolatility(xi, N, xbar) as vol;

------- Filter out zero volatilies
volatility = FILTER volatility BY vol != 0.0 AND vol < 1000 AND vol > -1000;

------- Sort by volatility
sorted_vol = ORDER volatility BY vol;
top10 = LIMIT sorted_vol 10;
sorted_vol = ORDER volatility BY vol DESC;
bottom10 = LIMIT sorted_vol 10;

X = UNION top10, bottom10;
Y = GROUP X BY 1;
result = FOREACH Y GENERATE FLATTEN(X);

------ Store the results
STORE result INTO 'hdfs:///pigdata/out_folder';
