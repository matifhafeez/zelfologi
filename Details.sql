truncate table [dbo].[Practitioner_Details]

;with AvailableHours as
(
	select 
	practitioner_id
	,weekday
	,start_time
	,end_time
	from WorkingHours 
	--where weekday = 'mon'
	--and practitioner_id = 131321
	union all	
	select 
	practitioner_id
	,weekday
	,start_time + 100
	,end_time
	from AvailableHours
	where start_time < (end_time - 100)
)
select practitioner_id
,weekday
,start_time
into #AvailableHours
from AvailableHours
order by practitioner_id, weekday, start_time
option(MAXRECURSION 1000)

;with NonAvailableHours as
(
	select AB.practitioner_id
	,C.weekday
	,AB.start_time
	,AB.end_time
	from AdhocBlocks AB
	inner join Calendar C on CAST(C.date AS date) = CAST(AB.date AS date) and AB.start_time = C.start_time 
	union all	
	select practitioner_id
	,weekday
	,start_time + 100
	,end_time
	from NonAvailableHours
	where start_time < (end_time - 100)
)
select practitioner_id
,weekday
,start_time
into #NonAvailableHours
from NonAvailableHours
order by practitioner_id

select AH.practitioner_id
,C.date as [date]
,AH.weekday
,AH.start_time
,case 
	when NAH.practitioner_id IS NOT NULL Then 'Not Available' 
	else 'Available' end as [Status]
into #ActualAvailableHours
from #AvailableHours AH
left join #NonAvailableHours NAH on 
	AH.practitioner_id = NAH.practitioner_id 
	and AH.weekday = NAH.weekday 
	and AH.start_time = NAH.start_time
left join Calendar C on
	AH.weekday = C.weekday 
	and AH.start_time = C.start_time

insert into [dbo].[Practitioner_Details]
select AAH.practitioner_id
,AAH.date
,AAH.weekday
,AAH.start_time
,case when B.practitioner_id IS NOT NULL then 'Booked' else AAH.Status end as [Status]
from #ActualAvailableHours AAH
left join Bookings B on 
	AAH.practitioner_id = B.practitioner_id
	and CAST(AAH.date AS date) = CAST(B.date AS date)
	and AAH.start_time = B.start_time
order by AAH.practitioner_id,AAH.date,AAH.start_time

drop table #ActualAvailableHours
drop table #NonAvailableHours
drop table #AvailableHours


