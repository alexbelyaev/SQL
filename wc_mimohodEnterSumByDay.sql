select e.NameEnter, CAST(se.TimeRecord as date) as ContDate, sum(se.SumIn) SumIn
from CM_StorageEnter se, CM_Enter e
where se.ID_Enter = e.ID_Enter
and e.IsEnabled = 1 and (e.ID_TypeEnter = 11 or e.NameEnter like '%имоход%')
and CAST(se.TimeRecord as date) = '2019-01-27'
group by e.ID_Enter, e.NameEnter, CAST(se.TimeRecord as date)