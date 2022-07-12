-- Qry1
SELECT
	sku.SKU				AS 'Product SKU',
	dep.DEPT_DESC		AS 'Department description',
	dep.DEPTDEC_DESC,
	sku.COLOR			AS 'Color',
	sku.CLASSIFICATION	AS 'Classification',
	sku.SKU_SIZE		AS 'Size',
	skustr.RETAIL		AS 'Retail Price'
FROM SKU sku
JOIN DEPARTMENT dep ON dep.DEPT = sku.DEPT
JOIN SKU_STORE skustr ON sku.SKU = skustr.SKU
WHERE
	dep.DeptDec_Desc = 'CAREER'
	AND sku.CLASSIFICATION = 'Sweater'
	AND dep.Dept_Desc = 'JONES SIGNATURE'
	AND skustr.RETAIL >= 100
UNION
SELECT
	sku.SKU				AS 'Product SKU',
	dep.DEPT_DESC		AS 'Department description',
	dep.DEPTDEC_DESC,
	sku.COLOR			AS 'Color',
	sku.CLASSIFICATION	AS 'Classification',
	sku.SKU_SIZE		AS 'Size',
	skustr.RETAIL		AS 'Retail Price'
FROM SKU sku
JOIN DEPARTMENT dep ON dep.DEPT = sku.DEPT
JOIN SKU_STORE skustr ON sku.SKU = skustr.SKU
WHERE
	sku.CLASSIFICATION = 'shoe'
	AND dep.Dept_Desc = 'Antonio Melani'
	AND skustr.RETAIL >= 250
ORDER BY
	dep.DEPT_DESC,
	skustr.RETAIL;

-- Qry2
SELECT DISTINCT
	cus.CUST_ID		AS 'Customer ID',
	cus.CITY		AS 'City',
	cus.STATE		AS 'State',
	cus.ZIP_CODE	AS 'Zip code'
FROM CUSTOMER cus
JOIN TRANSACT tra ON tra.CUST_ID = cus.CUST_ID
JOIN SKU sku ON sku.ITEM_ID = tra.ITEM_ID
JOIN DEPARTMENT dep ON dep.DEPT = sku.DEPT
WHERE
	cus.STATE = 'CA'
	AND dep.DEPT_DESC LIKE '%Lancome%'
	AND YEAR(tra.TRAN_DATE) = 2014
INTERSECT
SELECT DISTINCT
	cus.CUST_ID		AS 'Customer ID',
	cus.CITY		AS 'City',
	cus.STATE		AS 'State',
	cus.ZIP_CODE	AS 'Zip code'
FROM CUSTOMER cus
JOIN TRANSACT tra ON tra.CUST_ID = cus.CUST_ID
JOIN SKU sku ON sku.ITEM_ID = tra.ITEM_ID
JOIN DEPARTMENT dep ON dep.DEPT = sku.DEPT
WHERE
	cus.STATE = 'CA'
	AND dep.DEPT_DESC LIKE '%Chanel%'
	AND YEAR(tra.TRAN_DATE) = 2014
ORDER BY
	cus.CITY,
	cus.ZIP_CODE;

-- Qry3
SELECT
	CASE
		WHEN GROUPING(STATE) = 1
		THEN 'All'
		ELSE STATE
	END AS 'States',
	CASE
		WHEN GROUPING(CITY) = 1
		THEN 'All'
		ELSE CITY
	END AS 'Cities',
COUNT(*) AS 'NumOfStores'
FROM STORE
WHERE STATE IN ('NC','TX')
GROUP BY ROLLUP(STATE,CITY);

-- Qry4
SELECT
	CASE
		WHEN GROUPING(cus.STATE) = 1
		THEN 'All'
		ELSE cus.STATE
	END AS 'State',
	CASE
		WHEN GROUPING(cus.CITY) = 1
		THEN 'All'
		ELSE cus.CITY
	END AS 'City',
	CASE
		WHEN GROUPING(MONTH(tra.Tran_Date)) = 1
		THEN 'All'
		ELSE CAST(MONTH(tra.Tran_Date) AS VARCHAR(4))
	END AS 'Month',
FORMAT(SUM(tra.Tran_Amt),'C') AS 'Total Transaction Amount'
FROM CUSTOMER cus
JOIN TRANSACT tra ON cus.CUST_ID = tra.CUST_ID
WHERE
	cus.STATE = 'TX'
	AND cus.CITY IN ('HOUSTON','DALLAS','AUSTIN')
	AND YEAR(tra.Tran_Date) = 2015
	AND tra.tran_type = 'P'
GROUP BY cus.STATE, ROLLUP(cus.CITY, MONTH(tra.TRAN_DATE))
ORDER BY
	cus.STATE DESC,
	cus.CITY DESC,
	MONTH(tra.Tran_Date) ASC;

--Qry5
WITH DETAILS AS
(
    SELECT
		store.STATE				AS 'STATE',
		YEAR(tra.TRAN_DATE)		AS 'SalesYear',
		MONTH(tra.TRAN_DATE)	AS 'SalesMonth',
		SUM(tra.TRAN_AMT)		AS 'NikeMonthlySales'
    FROM DEPARTMENT dep
	INNER JOIN SKU ON dep.DEPT = SKU.DEPT
    INNER JOIN TRANSACT tra ON tra.ITEM_ID = SKU.ITEM_ID
	INNER JOIN STORE store ON store.STORE = tra.STORE
	WHERE
		tra.TRAN_TYPE = 'P'
		AND YEAR(tra.Tran_Date) = 2015
		AND dep.DEPT_DESC like 'NIKE%'
		AND store.STATE = 'TX'
	GROUP BY
		store.STATE,
		YEAR(tra.TRAN_DATE),
		MONTH(tra.TRAN_DATE)
),
ADDITONAL_DETAILS AS
(
	SELECT STATE,
	SalesYear,
	SalesMonth,
	SUM(NikeMonthlySales) OVER (ORDER BY SalesMonth) AS 'NikeCumulativeMonthlySales'
	FROM DETAILS
)
SELECT
	DETAILS.STATE,
	DETAILS.SalesYear,
	DETAILS.SalesMonth,
	FORMAT(DETAILS.NikeMonthlySales,'C')						AS 'NikeMonthlySales',
	FORMAT(ADDITONAL_DETAILS.NikeCumulativeMonthlySales,'C')	AS 'NikeCumulativeMonthlySales'
FROM DETAILS INNER JOIN ADDITONAL_DETAILS ON DETAILS.SalesMonth = ADDITONAL_DETAILS.SalesMonth
ORDER BY DETAILS.SalesMonth;

--Qry6
SELECT
	store.STORE							AS 'Stores',
	store.STATE							AS 'States',
	store.CITY							AS 'Cities',
	YEAR(tra.TRAN_DATE)					AS 'SalesYear',
	DATENAME(weekday, tra.TRAN_DATE)	AS 'WeekDays',
	FORMAT(SUM(tra.TRAN_AMT),'C')		AS 'CurrentYearWeekDaySales'
FROM STORE store
JOIN TRANSACT tra ON store.STORE = tra.STORE
WHERE
	YEAR(tra.TRAN_DATE) IN (2014, 2015)
	AND tra.TRAN_TYPE = 'P'
GROUP BY
	store.STORE,
	store.STATE,
	store.CITY,
	YEAR(tra.TRAN_DATE),
	DATENAME(weekday, tra.TRAN_DATE)
ORDER BY
	store.STORE,
	YEAR(tra.TRAN_DATE),
	SUM(tra.TRAN_AMT) DESC;

--Qry7
SELECT
	store.STORE							AS 'Stores',
	store.STATE							AS 'States',
	store.CITY							AS 'Cities',
	YEAR(tra.TRAN_DATE)					AS 'SalesYear',
	DATENAME(weekday, tra.TRAN_DATE)	AS 'WeekDays',
	FORMAT(SUM(tra.TRAN_AMT),'C')		AS 'CurrentYearWeekDaySales',
	FIRST_VALUE(DATENAME(weekday, tra.TRAN_DATE) + ': ' + FORMAT(SUM(tra.TRAN_AMT),'C')) OVER (PARTITION BY store.CITY, YEAR(tra.TRAN_DATE) ORDER BY SUM(tra.TRAN_AMT) DESC) AS 'HighestCurrentYearWeekDaySales',
	LAST_VALUE(DATENAME(weekday, tra.TRAN_DATE) + ': ' + FORMAT(SUM(tra.TRAN_AMT),'C')) OVER (PARTITION BY store.CITY, YEAR(tra.TRAN_DATE) ORDER BY SUM(tra.TRAN_AMT) DESC
			   RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'LowestCurrentYearWeekDaySales'
FROM STORE store
JOIN TRANSACT tra ON store.STORE = tra.STORE
WHERE
	YEAR(tra.TRAN_DATE) IN (2014, 2015)
	AND tra.TRAN_TYPE = 'P'
GROUP BY
	store.STORE,
	store.STATE,
	store.CITY,
	YEAR(tra.TRAN_DATE),
	DATENAME(weekday, tra.TRAN_DATE)
ORDER BY
	store.STORE,
	YEAR(tra.TRAN_DATE),
	SUM(tra.TRAN_AMT) DESC;

--Qry 8
SELECT
	store.STORE						AS 'Stores',
	store.STATE						AS 'States',
	store.CITY						AS 'Cities',
	YEAR(tra.TRAN_DATE)				AS 'SalesYear',
	FORMAT(SUM(tra.TRAN_AMT),'C')	AS 'CurrentYearSales',
	LAG(FORMAT(SUM(tra.TRAN_AMT), 'C'),1,'NA') OVER (PARTITION BY store.CITY ORDER BY YEAR(tra.TRAN_DATE)) AS 'LastYearSales',
	ISNULL(FORMAT(SUM(tra.TRAN_AMT) - LAG(SUM(tra.TRAN_AMT),1) OVER (PARTITION BY store.CITY ORDER BY YEAR(tra.TRAN_DATE)),'C'),'NA') AS 'ChangeInTotalYearlySales'
FROM STORE store
JOIN TRANSACT tra ON store.STORE = tra.STORE
WHERE
	YEAR(tra.TRAN_DATE) IN (2014,2015)
	AND tra.TRAN_TYPE = 'P'
GROUP BY
	store.STORE,
	store.STATE,
	store.CITY,
	YEAR(tra.TRAN_DATE)
ORDER BY
	store.STORE;