use Zelfologi

--select * from AdhocBlocks
--select * from Bookings order by practitioner_id,date
--select * from WorkingHours order by practitioner_id 
--select * from Calendar

--a percent of available practitioners for each concrete hour in a week

truncate table [dbo].[Summary]

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
,AH.weekday
,AH.start_time
--,NAH.practitioner_id as []
into #ActualWorkingHours
from #AvailableHours AH
left join #NonAvailableHours NAH on NAH.practitioner_id = AH.practitioner_id and NAH.weekday = AH.weekday and NAH.start_time = AH.start_time
where NAH.practitioner_id IS NULL
order by AH.practitioner_id

/*
	I have created a calendar table which contains the date range between 21st Feb till 25th Feb.
	For each date there are 24 rows (24 hours) therefore there are 120 rows in Calendar table
	I have joined this table with bookings table in order to get the Total Practitioners occupied for each concrete hour
	There is a case statement in aggregate function which will return 0 if the practitioner id is null. Otherwise it will count the rows.

*/
insert into [dbo].[Summary]
select occupied.date
,occupied.weekday
,occupied.weekday_number
,occupied.start_time
,occupied.[occupied by]
,ISNULL(duty.[on duty],0) as [on duty]
,ISNULL((duty.[on duty] - occupied.[occupied by]),0) as [free practitioners]
,ISNULL(CAST(duty.[on duty] - occupied.[occupied by] AS FLOAT) / CAST(duty.[on duty] AS FLOAT),0) as [%AGE of available practitioners]
from
(select A.date
	,A.weekday
	,A.weekday_number
	,A.start_time
	,sum(case when A.practitioner_id IS NOT NULL then 1 else 0 end) as [occupied by]
	from (select C.date
		,C.[weekday]
		,C.weekday_number
		,C.[start_time]
		,B.practitioner_id
		from Calendar C
		left join Bookings B on CAST(B.[date] AS date) = CAST(C.[date] AS date) and B.start_time = C.start_time
	) A
	group by A.date,A.[weekday],A.weekday_number,A.[start_time]
	--order by 1,2
) occupied
left join 
(select AWH.weekday
	,AWH.start_time
	,count(*) as [on duty]
	from #ActualWorkingHours AWH
	group by AWH.weekday,AWH.start_time) duty 
on duty.weekday = occupied.weekday and duty.start_time = occupied.start_time
order by 1,3,4

drop table #AvailableHours
drop table #NonAvailableHours
drop table #ActualWorkingHours
















