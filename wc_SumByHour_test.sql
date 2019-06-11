SELECT f.[NameFloor] AS 'Магазин',
CAST(se.[TimeStart] as date) AS 'Дата',
max(CONVERT(varchar(5), se.[TimeStart], 108)) AS 'время',
DATEPART(HH, se.[TimeStart]) AS 'Час',
SUM(CASE cze.[ID_Vector] when 1 then se.[SumIn] when 2 then se.[SumOut] end) as 'Вход'
--SUM(CASE cze.[ID_Vector] when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut
FROM dbo.[CM_StorageEnter] as se,
dbo.[CM_CrossZoneEnter] as cze,
dbo.[CM_Zone] as z,
dbo.[CM_Floor] as f
WHERE cze.[ID_Enter] = se.[ID_Enter]
AND z.[ID_Zone] = cze.[ID_Zone]
AND z.ID_Floor = f.ID_Floor
AND CAST(se.[TimeStart] as date) >= '2018-04-01'
AND CAST(se.[TimeStart] as date) <= '2018-04-30'
AND f.NameFloor LIKE '%013%'
GROUP BY f.NameFloor,
CAST(se.[TimeStart] AS DATE),
DATEPART(HH, se.[TimeStart]) WITH ROLLUP
--ORDER BY f.[NameFloor],
--CAST(se.[TimeStart] AS DATE),
--DATEPART(HH, se.[TimeStart]) 