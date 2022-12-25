-- 1. Buffer Cache Hit Ratio
SELECT ROUND(((1-(SUM(DECODE(name, 'physical reads', value,0))/
(SUM(DECODE(name, 'db block gets', value,0))+ 
(SUM(DECODE(name, 'consistent gets', value, 0))))))*100),2) || '%' "Buffer Cache Hit Ratio" 
FROM V$SYSSTAT; 

--2. Library Cache Hit Ratio
SELECT (1-SUM (reloads)/SUM(pins))*100 "Library Cache Hit Ratio"
From V$LIBRARYCACHE;

--3. Data Dictionary Cache Hit Ratio
SELECT (1-SUM(getmisses)/SUM(gets))*100 "Data Dictionary Hit Ratio"
FROM V$ROWCACHE;



