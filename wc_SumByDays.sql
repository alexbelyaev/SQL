SELECT f.[NameFloor],
CAST(se.[TimeStart] as date) AS Date,
SUM(CASE cze.[ID_Vector] when 1 then se.[SumIn] when 2 then se.[SumOut] end) as SumIn,
SUM(CASE cze.[ID_Vector] when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut
FROM dbo.[CM_StorageEnter] as se,
dbo.[CM_CrossZoneEnter] as cze,
dbo.[CM_Zone] as z,
dbo.[CM_Floor] as f
WHERE cze.[ID_Enter] = se.[ID_Enter]
AND z.[ID_Zone] = cze.[ID_Zone]
AND z.ID_Floor = f.ID_Floor
AND CAST(se.[TimeStart] as date) >= '2018-01-21'
AND CAST(se.[TimeStart] as date) <= '2018-01-24'
GROUP BY f.NameFloor,
CAST(se.[TimeStart] as date)
ORDER BY f.[NameFloor], Date

