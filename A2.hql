DROP TABLE IF EXISTS airline_2004;
-- create table
CREATE TABLE airline_2004 (
  Year INT,
  Month INT,
  DayofMonth INT,
  DayOfWeek INT,
  DepTime INT,
  CRSDepTime INT,
  ArrTime INT,
  CRSArrTime INT,
  UniqueCarrier STRING,
  FlightNum STRING,
  TailNum STRING,
  ActualElapsedTime INT,
  CRSElapsedTime INT,
  AirTime INT,
  ArrDelay INT,
  DepDelay INT,
  Origin STRING,
  Dest STRING,
  Distance INT,
  TaxiIn INT,
  TaxiOut INT,
  Cancelled INT,
  CancellationCode STRING,
  Diverted INT,
  CarrierDelay INT,
  WeatherDelay INT,
  NASDelay INT,
  SecurityDelay INT,
  LateAircraftDelay INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");-- delete line 1

LOAD DATA INPATH '/user/maria_dev/2004.csv' OVERWRITE INTO TABLE airline_2004;

SELECT * FROM airline_2004 LIMIT 10;

-- new view for analysis
CREATE VIEW valid_flights_2004 AS
SELECT *,
  CASE
    WHEN DepTime BETWEEN 500 AND 1159 THEN 'Morning'
    WHEN DepTime BETWEEN 1200 AND 1759 THEN 'Afternoon'
    WHEN DepTime >= 1800 OR DepTime < 500 THEN 'Evening'
    ELSE 'Unknown'
  END AS TimeOfDay
FROM airline_2004
WHERE Cancelled = 0 AND Diverted = 0 AND DepDelay IS NOT NULL;

SELECT COUNT(*) FROM valid_flights_2004; -- 6987729个

SELECT
  MIN(DepDelay) AS MinDelay,
  MAX(DepDelay) AS MaxDelay,
  AVG(DepDelay) AS AvgDelay
FROM valid_flights_2004;


-- 创建清洗后的有效航班视图，剔除异常延误值
CREATE VIEW clean_flights_2004 AS
SELECT *
FROM valid_flights_2004
WHERE DepDelay BETWEEN -60 AND 600;  -- 保留提前一小时以内 或 延误十小时以内的数据



SELECT COUNT(*) FROM clean_flights_2004;-- 6986980

-- 用clean_flights_2004 视图，这个是按时间段来分析平均的延误
SELECT 
  TimeOfDay,
  COUNT(*) AS TotalFlights,
  ROUND(AVG(DepDelay), 2) AS AvgDepDelay,
  ROUND(AVG(ArrDelay), 2) AS AvgArrDelay
FROM clean_flights_2004
GROUP BY TimeOfDay
ORDER BY AvgDepDelay;

-- 按星期分析
SELECT 
  DayOfWeek,
  COUNT(*) AS TotalFlights,
  ROUND(SUM(CASE WHEN DepDelay <= 0 THEN 1 ELSE 0 END) / COUNT(*), 3) AS OnTimeRate
FROM clean_flights_2004
GROUP BY DayOfWeek
ORDER BY OnTimeRate DESC;

-- 按月
SELECT 
  Month,
  COUNT(*) AS TotalFlights,
  ROUND(SUM(CASE WHEN DepDelay <= 0 THEN 1 ELSE 0 END) / COUNT(*), 3) AS OnTimeRate
FROM clean_flights_2004
GROUP BY Month
ORDER BY OnTimeRate DESC;

-- 延误因素
-- 计算各延误类型总分钟数及占比
SELECT 
  DelayType,
  TotalMinutes,
  ROUND(Percentage, 2) AS Percentage
FROM (
  SELECT 
    'CarrierDelay' AS DelayType,
    SUM(CarrierDelay) AS TotalMinutes,
    100.0 * SUM(CarrierDelay) / total_delay.Total AS Percentage
  FROM airline_2004
  CROSS JOIN (
    SELECT 
      SUM(CarrierDelay + WeatherDelay + NASDelay + SecurityDelay + LateAircraftDelay) AS Total
    FROM airline_2004
    WHERE CarrierDelay > 0 OR WeatherDelay > 0 OR NASDelay > 0 OR SecurityDelay > 0 OR LateAircraftDelay > 0
  ) AS total_delay
  WHERE CarrierDelay > 0
  GROUP BY total_delay.Total
  
  UNION ALL
  
  SELECT 
    'WeatherDelay' AS DelayType,
    SUM(WeatherDelay),
    100.0 * SUM(WeatherDelay) / total_delay.Total
  FROM airline_2004
  CROSS JOIN (
    SELECT 
      SUM(CarrierDelay + WeatherDelay + NASDelay + SecurityDelay + LateAircraftDelay) AS Total
    FROM airline_2004
    WHERE CarrierDelay > 0 OR WeatherDelay > 0 OR NASDelay > 0 OR SecurityDelay > 0 OR LateAircraftDelay > 0
  ) AS total_delay
  WHERE WeatherDelay > 0
  GROUP BY total_delay.Total
  
  UNION ALL
  
  SELECT 
    'NASDelay' AS DelayType,
    SUM(NASDelay),
    100.0 * SUM(NASDelay) / total_delay.Total
  FROM airline_2004
  CROSS JOIN (
    SELECT 
      SUM(CarrierDelay + WeatherDelay + NASDelay + SecurityDelay + LateAircraftDelay) AS Total
    FROM airline_2004
    WHERE CarrierDelay > 0 OR WeatherDelay > 0 OR NASDelay > 0 OR SecurityDelay > 0 OR LateAircraftDelay > 0
  ) AS total_delay
  WHERE NASDelay > 0
  GROUP BY total_delay.Total
  
  UNION ALL
  
  SELECT 
    'SecurityDelay' AS DelayType,
    SUM(SecurityDelay),
    100.0 * SUM(SecurityDelay) / total_delay.Total
  FROM airline_2004
  CROSS JOIN (
    SELECT 
      SUM(CarrierDelay + WeatherDelay + NASDelay + SecurityDelay + LateAircraftDelay) AS Total
    FROM airline_2004
    WHERE CarrierDelay > 0 OR WeatherDelay > 0 OR NASDelay > 0 OR SecurityDelay > 0 OR LateAircraftDelay > 0
  ) AS total_delay
  WHERE SecurityDelay > 0
  GROUP BY total_delay.Total
  
  UNION ALL
  
  SELECT 
    'LateAircraftDelay' AS DelayType,
    SUM(LateAircraftDelay),
    100.0 * SUM(LateAircraftDelay) / total_delay.Total
  FROM airline_2004
  CROSS JOIN (
    SELECT 
      SUM(CarrierDelay + WeatherDelay + NASDelay + SecurityDelay + LateAircraftDelay) AS Total
    FROM airline_2004
    WHERE CarrierDelay > 0 OR WeatherDelay > 0 OR NASDelay > 0 OR SecurityDelay > 0 OR LateAircraftDelay > 0
  ) AS total_delay
  WHERE LateAircraftDelay > 0
  GROUP BY total_delay.Total
) AS delays
ORDER BY TotalMinutes DESC
LIMIT 5;

-- 取消分析
-- 取消原因和分布
SELECT 
  CancellationCode,
  COUNT(*) AS CancelCount
FROM airline_2004
WHERE Cancelled = 1
GROUP BY CancellationCode
ORDER BY CancelCount DESC;

-- 按航空公司统计取消
SELECT
  UniqueCarrier,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent
FROM airline_2004
GROUP BY UniqueCarrier
ORDER BY CancelRatePercent DESC;

-- 按出发机场统计取消
SELECT
  Origin,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent
FROM airline_2004
GROUP BY Origin
ORDER BY CancelRatePercent DESC
LIMIT 20;

-- 按月份统计取消率
SELECT
  Month,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent
FROM airline_2004
GROUP BY Month
ORDER BY CancelRatePercent DESC;

-- 按时间段统计取消
CREATE OR REPLACE VIEW cancellation_time_of_day AS
SELECT *,
  CASE
    WHEN CRSDepTime BETWEEN 500 AND 1159 THEN 'Morning'
    WHEN CRSDepTime BETWEEN 1200 AND 1759 THEN 'Afternoon'
    WHEN CRSDepTime >= 1800 OR CRSDepTime < 500 THEN 'Evening'
    ELSE 'Unknown'
  END AS TimeOfDay
FROM airline_2004
WHERE Cancelled = 1;

SELECT
  TimeOfDay,
  COUNT(*) AS CancelCount
FROM cancellation_time_of_day
GROUP BY TimeOfDay
ORDER BY CancelCount DESC;


-- 问题航线分析
-- 取消率和延误率都高的航线（Origin-Dest）
SELECT
  Origin,
  Dest,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent,
  ROUND(AVG(DepDelay), 2) AS AvgDepDelay,
  ROUND(AVG(ArrDelay), 2) AS AvgArrDelay
FROM airline_2004
GROUP BY Origin, Dest
HAVING COUNT(*) > 100  -- 过滤航班量太少的航线
ORDER BY CancelRatePercent DESC, AvgDepDelay DESC
LIMIT 20;

--  按承运人（UniqueCarrier）统计平均延误和取消率
SELECT
  UniqueCarrier,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent,
  ROUND(AVG(DepDelay), 2) AS AvgDepDelay,
  ROUND(AVG(ArrDelay), 2) AS AvgArrDelay
FROM airline_2004
GROUP BY UniqueCarrier
ORDER BY CancelRatePercent DESC, AvgDepDelay DESC
LIMIT 10;

-- 按航班号统计延误和取消
SELECT
  FlightNum,
  COUNT(*) AS TotalFlights,
  SUM(Cancelled) AS CancelledFlights,
  ROUND(SUM(Cancelled)*100.0/COUNT(*), 2) AS CancelRatePercent,
  ROUND(AVG(DepDelay), 2) AS AvgDepDelay,
  ROUND(AVG(ArrDelay), 2) AS AvgArrDelay
FROM airline_2004
GROUP BY FlightNum
HAVING COUNT(*) > 50
ORDER BY CancelRatePercent DESC, AvgDepDelay DESC
LIMIT 20;

-- 找问题最多的航班
SELECT
  Origin,
  Dest,
  UniqueCarrier,
  FlightNum,
  AVG(CarrierDelay) AS AvgCarrierDelay,
  AVG(WeatherDelay) AS AvgWeatherDelay,
  AVG(NASDelay) AS AvgNASDelay,
  AVG(SecurityDelay) AS AvgSecurityDelay,
  AVG(LateAircraftDelay) AS AvgLateAircraftDelay,
  AVG(DepDelay) AS AvgDepDelay,
  SUM(Cancelled) AS CancelledFlights,
  COUNT(*) AS TotalFlights
FROM airline_2004
GROUP BY Origin, Dest, UniqueCarrier, FlightNum
HAVING COUNT(*) > 50
ORDER BY CancelledFlights DESC, AvgDepDelay DESC
LIMIT 20;
