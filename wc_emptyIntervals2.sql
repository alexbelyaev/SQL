DECLARE @DateFrom date
DECLARE @DateTo date
DECLARE @TimeFrom time
DECLARE @TimeTo time
SET @TimeFrom = '10:00:00'
SET @TimeTo = '21:45:00'
--SET @DateFrom = '2018-02-19'
SET @DateFrom = DATEADD(DAY,-1, cast(getdate() as date))
--SET @DateFrom = cast(getdate() as date)

SET @DateTo = @DateFrom

select * from (
select 
	t2.Controller,
	z.NameZone,
	--t1.DateStart, 
	CONVERT(varchar, t1.DateEnd, 104) DateEnd, 
	LEFT(CONVERT(varchar, t1.TimeStart, 8),5) TimeStart, 
	LEFT(CONVERT(varchar, t1.TimeEND, 8),5) TimeEND, 
	t1.EmpHours,
	LEFT(CONVERT(varchar, t3.MinTimeIn, 8),5) MinTimeIn7,
	LEFT(CONVERT(varchar, t3.MaxTimeOut, 8),5) MaxTimeOut7,
	CAST(((SumIn - SumOut) * 1.0 / ABS(Coalesce(NULLIF(SumOut,0),1)) * 100) AS DECIMAL(8,2)) AS Diff, 
	--t2.DateSum,
	t2.SumIn, 
	t3.SumIn7,
	t2.SumOut,
	t3.SumOut7,
	CAST(((SumIn - SumIn7) * 1.0 / ABS(Coalesce(NULLIF(SumIn7,0),1)) * 100) AS DECIMAL(8,2)) AS DiffIn,
	CAST(((SumOut - SumOut7) * 1.0 / ABS(Coalesce(NULLIF(SumOut7,0),1)) * 100) AS DECIMAL(8,2)) AS DiffOut
from 
	CM_Zone z
	LEFT OUTER JOIN
	(select 
		t.ID_Zone, 
		(select NameZone from CM_Zone where ID_Zone = t.ID_Zone) NameFloor,
		cast(min(t.TimeRecord) as date) DateStart,
		cast(max(t.TimeRecord) as date) DateEnd,
		min(t.TimeRecord) TimeStart,
		max(t.TimeRecord) TimeEnd,
		CAST(((DATEDIFF(minute, min(t.TimeRecord),max(t.TimeRecord)))*1.0/60)AS DECIMAL(5,2)) EmpHours
	from (
		select 	cze.ID_Zone,
				(select NameZone from CM_Zone where ID_Zone = cze.ID_Zone) NameFloor,
				TimeRecord,
				--count(*),
				SUM(CASE cze.ID_Vector when 1 then se.[SumIn] when 2 then se.[SumOut] end) as SumIn,
				SUM(CASE cze.ID_Vector when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut,
				sum(case when (sum(SumIn) > 0 OR sum(SumOut) > 0) then 1 else 0 end) over (order by cze.ID_Zone, se.TimeRecord desc) as Grp
		from (select ID_Enter, TimeRecord, SumIn, SumOut 
				from CM_StorageEnter where cast(TimeRecord as time) >= @TimeFrom
					and cast(TimeRecord as time) < @TimeTo
					and cast(TimeRecord as date) >= @DateFrom
					and cast(TimeRecord as date) <= @DateTo
				UNION 
					select ID_Enter, (CAST(@DateFrom as datetime) + CAST(@TimeFrom as datetime)) as TimeRecord, 1 as SumIn, 1 as SumOut from CM_Enter where IsEnabled = 1
				UNION 
					select ID_Enter, (CAST(@DateTo as datetime) + CAST(@TimeTo as datetime)) as TimeRecord, 1 as SumIn, 1 as SumOut from CM_Enter where IsEnabled = 1
				) se, 
				CM_CrossZoneEnter cze
		where se.ID_Enter = cze.ID_Enter 
		group by cze.ID_Zone, se.TimeRecord
		) t
	group by t.ID_Zone, Grp
	having DATEDIFF(minute, min(TimeRecord),max(TimeRecord)) >= 60
	--having (min(SumIn)=0 and min(SumOut)=0)
	--ORDER BY t.ID_Enter, DateStart, TimeStart
	) t1 ON t1.ID_Zone = z.ID_Zone
LEFT OUTER JOIN --ясллю он бундс х бшундс
	(select 
		ID_Zone,
			(select max(
					CASE ID_TypeController
						when '20' then 'CountMax 3D'
						when '25' then 'CountMax 2D'
						when '204' then 'Xovis'
						when '206' then 'Xovis'
						when '200' then 'CountMax 3D Live'
						when '240' then 'Vivotek'
					END)
			from CM_Controller c, CM_Sensor s 
			where s.ID_Enter = max(se.ID_Enter) and s.ID_Controller = c.ID_Controller) Controller, 
			cast(TimeRecord as date) 
		DateSum, 
		SUM(CASE cze.ID_Vector when 1 then se.[SumIn] when 2 then se.[SumOut] end) as SumIn,
		SUM(CASE cze.ID_Vector when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut
	from CM_StorageEnter se, CM_CrossZoneEnter cze
	WHERE se.ID_Enter = cze.ID_Enter
		and cast(TimeRecord as date) >= @DateFrom
		and cast(TimeRecord as date) <= @DateTo
	group by 
		ID_Zone, 
		cast(TimeRecord as date)
	) t2 ON t2.ID_Zone = z.ID_Zone
LEFT OUTER JOIN ( --7 дмеи мюгюд
	select 
		ID_Zone,
		cast(TimeRecord as date) DateSum2,
		SUM(CASE cze.ID_Vector when 1 then se.[SumIn] when 2 then se.[SumOut] end) as SumIn7,
		SUM(CASE cze.ID_Vector when 1 then se.[SumOut] when 2 then se.[SumIn] end) as SumOut7,
		(
			select cast(min(TimeRecord) as time) 
			from CM_StorageEnter se2, CM_CrossZoneEnter cze2
			WHERE se2.ID_Enter = cze2.ID_Enter
			and cze2.ID_Zone = cze.ID_Zone
			and cast(TimeRecord as date) = cast(se.TimeRecord as date)
			and SumIn > 0
		) 
		MinTimeIn,
		(
			select cast(max(TimeRecord) as time) 
			from CM_StorageEnter se2, CM_CrossZoneEnter cze2
			WHERE se2.ID_Enter = cze2.ID_Enter
			and cze2.ID_Zone = cze.ID_Zone
			and cast(TimeRecord as date) = cast(se.TimeRecord as date)
			and SumOut > 0
		) 
		MaxTimeOut
	from CM_StorageEnter se, CM_CrossZoneEnter cze
	WHERE se.ID_Enter = cze.ID_Enter
		and cast(TimeRecord as date) >= DATEADD(day, -7, cast(@DateFrom as date))
		and cast(TimeRecord as date) <= DATEADD(day, -7, cast(@DateTo as date))
	group by 
		ID_Zone, 
		cast(TimeRecord as date)
	) t3 ON t3.ID_Zone = z.ID_Zone AND t2.DateSum = DATEADD(day, 7, DateSum2)
) r
where (((EmpHours > 1 AND SumIn > 150) 
OR (EmpHours > 2))
AND ABS(DATEDIFF(minute, MaxTimeOut7, CAST(TimeStart as TIME))) > 30
)
OR (ABS(Diff) > 20)
OR (Controller = 'Xovis' AND ABS(Diff) > 7)
OR (Controller IN ('CountMax 3D', 'CountMax 3D Live', 'Vivotek') AND ABS(Diff) > 10)
OR (ABS(DiffIn) > 150)
OR (ABS(DiffOut) > 150)
OR (SumIn > 300 AND ABS(DiffIn) > 60)
OR (SumOut > 300 AND ABS(DiffOut) > 60)
order by ISNULL(DateEnd, '2222-02-02'),EmpHours DESC, TimeStart, NameZone