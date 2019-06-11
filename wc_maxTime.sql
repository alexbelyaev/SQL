--select ID_Sensor, max(TimeRecord) from CM_StorageSensor group by ID_Sensor

SELECT * FROM (
SELECT *, DATEDIFF(hour, MaxTime, CurrTime) DiffTime FROM (
SELECT 
s.ID_Sensor,
e.NameEnter,
c.AddHour,
--c.DateOffline,
(SELECT MAX(TimeEnd) FROM CM_StorageSensor WHERE ID_Sensor = s.ID_Sensor) MaxTime, 
DATEADD(HOUR, c.AddHour, GETUTCDATE()) CurrTime
FROM CM_Sensor s, CM_Controller c, CM_Enter e
WHERE s.ID_Controller = c.ID_Controller
and s.ID_Enter = e.ID_Enter
and s.IsEnabled = 1 ) t
) t2 WHERE DiffTime > 5


/* в минутах, с условием если привышает 15 мин

SELECT * FROM (
SELECT *, DATEDIFF(minute, MaxTime, CurrTime) DiffTime FROM (
SELECT 
s.ID_Sensor,
e.NameEnter,
c.AddHour,
--c.DateOffline,
(SELECT MAX(TimeEnd) FROM CM_StorageSensor WHERE ID_Sensor = s.ID_Sensor) MaxTime, 
DATEADD(HOUR, c.AddHour, GETUTCDATE()) CurrTime
FROM CM_Sensor s, CM_Controller c, CM_Enter e
WHERE s.ID_Controller = c.ID_Controller
and s.ID_Enter = e.ID_Enter
and s.IsEnabled = 1 ) t
) t2 WHERE DiffTime < 0
OR  DiffTime > 15
order by ABS(DiffTime) desc

*/