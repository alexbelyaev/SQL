DECLARE @Date datetime
SET @Date = DATEADD(DAY,-1, cast(getdate() as date))
--((V2 - V1) / Math.Abs(V1)) * 100;
SELECT *, 
CASE Controller
			when '20' then 'CountMax 3D'
			when '25' then 'CountMax 2D'
			when '204' then 'Xovis'
			when '206' then 'Xovis'
			when '200' then 'CountMax 3D Live'
			when '240' then 'Vivotek'
END ControllerName
FROM (
SELECT 
	*, 
	CAST(((SumIn - SumOut) * 1.0 / ABS(Coalesce(NULLIF(SumOut,0),1)) * 100) AS DECIMAL(8,2)) AS Diff,
	(select max(ID_TypeController)
			from CM_Controller where ID_Floor = ST.ID_Floor) Controller
FROM (
SELECT	z.ID_Project,
		z.ID_Floor,
		cze.[ID_Zone] as IdZone, 
		z.NameZone,
		CAST(se.[TimeStart] as DATE) AS DtReport, 
		SUM(CASE cze.[ID_Vector] when 1 then se.[SumIn] when 2 then se.[SumOut] end) as SumIn, 
		SUM(CASE cze.[ID_Vector] when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut 
FROM dbo.[CM_StorageEnter] as se 
		INNER JOIN dbo.[CM_CrossZoneEnter] as cze 
			ON cze.[ID_Enter] = se.[ID_Enter] 
        JOIN [CM_Zone] as z 
			ON z.[ID_Zone] = cze.[ID_Zone] 
WHERE (CAST (se.[TimeRecord] AS DATE) = @Date) 
AND ID_Floor NOT IN (66972915)
AND ID_Project NOT IN (21860460) 
--AND cze.[ID_Zone] = @IdZone 
GROUP BY 
z.ID_Project,
z.ID_Floor,
cze.[ID_Zone], 
z.NameZone,
CAST(se.[TimeStart] AS DATE)  
) AS ST 
) AS ST2
WHERE (Controller in (20,204,206,200,240) AND ABS(Diff) > 7)
OR ABS(Diff) > 20
ORDER BY Diff 