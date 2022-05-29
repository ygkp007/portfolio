-- INSERTING DATA
  
 USE portfolioproject;
  
  SELECT *
  FROM sales_data_sample;
  -- CHECKING  UNIQUE VALUES
  SELECT DISTINCT status FROM sales_data_sample; -- One to plot in Tableau
  SELECT DISTINCT YEAR_ID FROM sales_data_sample; 
  SELECT DISTINCT PRODUCTLINE FROM sales_data_sample; -- One to plot in Tableau
  SELECT DISTINCT COUNTRY FROM sales_data_sample; -- One to plot in Tableau
  SELECT DISTINCT DEALSIZE FROM sales_data_sample; -- One to plot in Tableau
  SELECT DISTINCT TERRITORY FROM sales_data_sample; -- One to plot in Tableau


  -- Analysis

  -- First grouping sales by productline

  SELECT PRODUCTLINE, SUM(sales) AS revenue
  FROM sales_data_sample
  GROUP BY PRODUCTLINE
  ORDER BY 2 DESC;

  SELECT YEAR_ID, SUM(sales) AS revenue
  FROM sales_data_sample
  GROUP BY YEAR_ID
  ORDER BY 2 DESC;

  -- As we see from the result the 2005 sales is very less
  SELECT DISTINCT MONTH_ID FROM sales_data_sample
  WHERE YEAR_ID = 2005; 
  -- As we can see they only operated for 5 months in 2005 this is why their revenue is so less in 2005.

  SELECT DEALSIZE, SUM(sales) AS revenue
  FROM sales_data_sample
  GROUP BY DEALSIZE
  ORDER BY 2 DESC;

  --What was the best month for sales in a specific year and how much was earned that month?

  SELECT MONTH_ID, SUM(sales) AS revenue, COUNT(ORDERNUMBER) AS frequency
  FROM sales_data_sample
  WHERE YEAR_ID = 2003
  GROUP BY MONTH_ID
  ORDER BY 2 DESC;

  --In both 2003, 2004 best month is november so, let's see what prooduct they sell most in november
  -- i'm not including 2005 because we only have first five month of data.

  SELECT MONTH_ID, productline, SUM(sales) AS revenue, COUNT(ORDERNUMBER) AS frequency
  FROM sales_data_sample
  WHERE YEAR_ID = 2003 AND MONTH_ID = 11
  GROUP BY MONTH_ID, PRODUCTLINE
  ORDER BY 3 DESC;

  -- Who is best customer(best answered with RFM)
  --(R = RECENCY - last order date)
  --(F = frequency - count of total orders)
  --(M = Monetary value - total spend)


DROP TABLE IF EXISTS #rfm
;WITH RFM AS
(
	SELECT 
		CUSTOMERNAME,
		SUM(SALES) AS monetary_value,
		AVG(SALES) AS avg_monetary_value,
		COUNT(ORDERNUMBER) AS frequency,
		MAX(ORDERDATE) AS last_order_date,
		(SELECT MAX(ORDERDATE) FROM sales_data_sample) AS max_order_date,
		DATEDIFF(DD,MAX(ORDERDATE),(SELECT MAX(ORDERDATE) FROM sales_data_sample)) AS recency
	FROM sales_data_sample
	GROUP BY CUSTOMERNAME
),
rfm_calc AS
(
 
	SELECT r.*,
		NTILE(4) OVER (ORDER BY recency DESC) AS RFM_recency,
		NTILE(4) OVER (ORDER BY frequency) AS RFM_frequency,
		NTILE(4) OVER (ORDER BY monetary_value) AS RFM_monetary
	FROM RFM AS r
)
SELECT c.*, RFM_recency + RFM_frequency + RFM_monetary AS rfm_cell
	, CAST(RFM_recency AS VARCHAR) + CAST(RFM_frequency AS VARCHAR) + CAST(RFM_monetary AS VARCHAR) AS rfm_cell_string
INTO #rfm
FROM rfm_calc AS c

SELECT *
FROM #rfm

SELECT MAX(RFM_recency), MAX(RFM_frequency), MAX(RFM_monetary)
FROM #rfm

SELECT CUSTOMERNAME, RFM_recency , RFM_frequency , RFM_monetary,
	CASE
		WHEN rfm_cell_string in (111,112,121,122,123,132,211,212,114,141) THEN 'lost customers'  -- Lost Customers
		WHEN rfm_cell_string in(133,134,143,244,334,343,344) THEN 'slipping away, cannot losse'
		WHEN rfm_cell_string in(311,411,331) THEN 'new customers'
		WHEN rfm_cell_string in(222,223,233,322) THEN 'potential churners'
		WHEN rfm_cell_string in(323,333,321,422,332,432) THEN 'active'
		WHEN rfm_cell_string in(433,434,443,444) THEN 'loyal'
	END rfm_segment
FROM #rfm


--What products are most often sold together. 
-- SELECT * FROM sales_data_sample WHERE ORDERNUMBER = 10411; -- As we can see there are multiple products for one order number so, lets check any one order number.


SELECT DISTINCT ordernumber, STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM sales_data_sample AS p
	WHERE ORDERNUMBER IN
		(
		SELECT ORDERNUMBER
		FROM (
			SELECT ORDERNUMBER, COUNT(*) AS rn
			FROM sales_data_sample
			WHERE STATUS = 'shipped'
			GROUP BY ORDERNUMBER 
		) AS shipped_ordernumber
		WHERE rn = 2	
		)
		AND p.ORDERNUMBER = s.ORDERNUMBER
		FOR XML PATH (''))
		
		,1, 1, '') AS productcodes
FROM sales_data_sample AS s
ORDER BY 2 DESC;