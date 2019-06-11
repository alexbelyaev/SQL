DECLARE @Code VARCHAR(5) = '3' --Код магазина, для показа информации

SELECT  z.NameZone,
		e.NameEnter, 
		con.IpAddress,
		con.IpPort,
		c.SerNomer,
		(SELECT Name FROM CM_TypeController WHERE ID = c.ID_TypeController) as TypeController,
		c.AddHour,
		(SELECT Name FROM CM_TypeMetric WHERE ID = s.ID_TypeMetric) AS Metric,
		(SELECT Name FROM CM_TypeSensor WHERE ID = s.ID_TypeSensor) AS Sensor,
		s.NomerInController AS cPort,
		s.ID_TypeVector AS sVector,
		f.NameFloor,
		(SELECT (cti.FullName + ' (' + cntr.Name + ')') FROM CM_City cti, CM_Region reg, CM_Country cntr
			WHERE cti.ID_Region = reg.ID
			AND reg.ID_Country = cntr.ID
			AND cti.ID = f.ID_City) AS City,
		f.Code1C,
		p.Comment
FROM
	CM_Project p, 
	CM_Floor f,
	CM_Zone z,
	CM_Enter e,
	CM_CrossZoneEnter ze,
	CM_Controller c,
	CM_Sensor s,
	CM_Connection con
WHERE p.ID_Project = f.ID_Project 
AND z.ID_Floor = f.ID_Floor
AND e.ID_Floor = f.ID_Floor
AND ze.ID_Enter = e.ID_Enter AND ze.ID_Zone = z.ID_Zone
AND s.ID_Enter = e.ID_Enter AND s.ID_Controller = c.ID_Controller
AND con.ID_Connection = c.ID_Connection
AND f.NameFloor LIKE '%'+@Code+'%'