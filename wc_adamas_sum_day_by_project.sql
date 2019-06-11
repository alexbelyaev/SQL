select sum(SumIn) sumin,sum(SumOut)sumout , ((sum(SumIn) + sum(SumOut)) /2) as avg
from CM_StorageEnter se,
CM_CrossZoneEnter cze,
CM_Zone z
where se. ID_Enter=cze.ID_Enter
and z.ID_Zone = cze.ID_Zone
and z.IsEnabled=1
and cast(se.TimeRecord as date) ='2019-04-20'
group by cast(se.TimeRecord as date)
