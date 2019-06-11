select 
(select NameFloor from CM_Floor f, CM_Controller c where c.ID_Floor = f.ID_Floor and c.ID_Controller = err.ID_Controller) FloorName, 
(select Name from CM_TypeError where ID = err.ID_TypeError) ErrName, *
from CM_StorageControllerError err
where cast(TimeRecord as date) = DATEADD(DAY,-1, cast(getdate() as date)) 
and cast(TimeRecord as time) between '10:00:00' and '21:00:00'
and ID_TypeError IN (5017, 47, 50, 46, 70, 2006)
order by FloorName