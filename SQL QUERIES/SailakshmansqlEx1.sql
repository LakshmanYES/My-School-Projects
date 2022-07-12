-- Query 1
SELECT DISTINCT ven.VendorID, ven.VendorName
FROM Vendors ven JOIN Invoices inv ON ven.VendorID = inv.VendorID
WHERE (inv.InvoiceTotal - inv.PaymentTotal - inv.CreditTotal) <= 0
	--AND (inv.InvoiceDate BETWEEN '2019-11-01' AND '2019-12-31')
	AND YEAR(inv.InvoiceDate) = 2019
	AND MONTH(inv.InvoiceDate) IN (11, 12)
ORDER BY ven.VendorName

-- Query2
SELECT
	CASE
	   WHEN GROUPING (ven.VendorState) = 1
	   THEN 'All'
	   ELSE ven.VendorState 
	END AS VendorState,
	CASE
		WHEN GROUPING(ven.VendorCity) = 1
		THEN 'All'
		ELSE ven.VendorCity
	END AS VendorCity, 
COUNT(inv.InvoiceID) AS NumOfInvoices
FROM Vendors ven JOIN Invoices inv ON inv.VendorID = ven.VendorID
WHERE ven.VendorState IN ('CA', 'NV')
GROUP BY ROLLUP(ven.VendorState, ven.VendorCity);

-- Query 3
SELECT
	CASE
	   WHEN GROUPING(ven.VendorState) = 1 THEN 'All'
	   ELSE ven.VendorState
	END AS VendorStates,
	CASE
		WHEN GROUPING(ven.VendorCity) = 1 THEN 'All'
		ELSE ven.VendorCity
	END AS VendorCities,
	CASE
		WHEN GROUPING(MONTH(inv.InvoiceDate)) = 1 THEN 'All'
		ELSE CAST(MONTH(inv.InvoiceDate) AS VARCHAR(3))
	END AS InvoiceMonths,
FORMAT(SUM(inv.InvoiceTotal), 'C') AS TotalOfInvoices
FROM Vendors ven JOIN Invoices inv ON inv.VendorID = ven.VendorID
WHERE ven.VendorState IN ('OH', 'NV')
	AND YEAR(inv.InvoiceDate) = 2019
	AND MONTH(inv.InvoiceDate) IN (10,11,12)
GROUP BY ROLLUP(ven.VendorState, ven.VendorCity, MONTH(inv.InvoiceDate)) 
ORDER BY
	ven.VendorState DESC,
	ven.VendorCity DESC,
	MONTH(inv.InvoiceDate)DESC;

-- Query 4
WITH MonthlyAmounts AS
(
SELECT
	ven.VendorName			AS VendorName,
	YEAR(inv.InvoiceDate)	AS InvoiceYear,
	MONTH(inv.InvoiceDate)	AS InvoiceMonth,
	SUM(inv.InvoiceTotal)	AS FedExMonthlyAmount
FROM dbo.Vendors ven JOIN dbo.Invoices inv ON inv.VendorID = ven.VendorID
WHERE ven.VendorName = 'Federal Express Corporation'
	AND YEAR(inv.InvoiceDate) = 2019
	AND MONTH(inv.InvoiceDate) IN (10, 11, 12)
GROUP BY ven.VendorName, YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate)
)
SELECT VendorName, InvoiceYear, InvoiceMonth, FORMAT(FedExMonthlyAmount, 'C') AS FedExMonthlyAmounts,
FORMAT(SUM(FedExMonthlyAmount) OVER (ORDER BY InvoiceMonth), 'C') AS FedExCumulativeMonthlyInvoiceTotals
FROM MonthlyAmounts;