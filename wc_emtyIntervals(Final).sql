WITH Zones AS (

select z.ID_Zone,
z.NameZone,
IIF(convert(varchar(8), z.TimeOpen, 108) = '00:00:00', '10:00:00', z.TimeOpen) TimeOpen,
IIF(convert(varchar(8), z.TimeClose, 108) = '00:00:00', '22:00:00', z.TimeClose) TimeClose,
z.TimeInterval
from CM_Zone z, CM_Floor f
where z.ID_Floor = f.ID_Floor
and z.IsEnabled = 1
and f.IsEnabled = 1

), 

ZoneStorageEnter AS (

select	cze.ID_Zone,
		se.TimeEnd,
		sum(SumIn) OVER (PARTITION BY ID_Zone) SumIn
from	CM_CrossZoneEnter cze,
		CM_StorageEnter se 
where cze.ID_Enter = se.ID_Enter
and cast(se.TimeRecord as date) = '2019-04-26'
and (SumIn > 0 or SumOut > 0)  

),

StorageZoneByDay AS (

select	z.ID_Zone,
		cast(zse.TimeEnd as time) TimeEnd,
		max(z.TimeInterval) TimeInterval,
		max(z.TimeOpen) TimeOpen,
		max(z.TimeClose) TimeClose,
		max(SumIn) SumInDay
from	Zones z 
		left join  ZoneStorageEnter zse
			on z.ID_Zone = zse.ID_Zone
			and cast(zse.TimeEnd as time) < cast(z.TimeClose as time)
			and cast(zse.TimeEnd as time) >= cast(z.TimeOpen as time)
group by z.ID_Zone, TimeEnd
)
--select * from StorageZoneByDay
,
intervals as (

select ID_Zone, (select NameZone from CM_Zone z2 where z2.ID_Zone = sbd.ID_Zone) NameZone,
lag(TimeEnd,1,TimeOpen) OVER (PARTITION BY ID_Zone ORDER BY ID_Zone, TimeEnd) TimeStart, 
COALESCE(DATEADD(SECOND, -TimeInterval, TimeEnd), cast(TimeClose as time)) TimeEnd, SumInDay
from StorageZoneByDay sbd

)

select *, DATEDIFF(minute, TimeStart, TimeEnd) diff from intervals 
where DATEDIFF(minute, TimeStart, TimeEnd) >= 150
OR (
DATEDIFF(minute, TimeStart, TimeEnd) >= 60
AND SumInDay > 200
)
order by 3
