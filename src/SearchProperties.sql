/*
Written by Bruce Jernell
v1.0

This script searches for properties inside of OpCon and outputs
the Location and Usage of the property.  The script does NOT
search the daily jobs or history tables.

Set the "property" sql variable equal to the property you wish to
search, minus the [[ ]].
*/
Use Opconxps --Your OpCon db name
declare @property varchar(300)
set @property = '$DATE' --Property to search for, without [[ ]]

		/* Job Master */
		Select 
			'Job Master: ' + Sk.Skdname + ' -> ' + JM.JobName as [Location]
			,JM.JaValue as [Usage]
		From JMASTER_AUX as JM
		Join SNAME as Sk
			on Sk.SKDID = JM.Skdid
		Where
			JM.JAVALUE like '%`[`[' + @Property + '`]`]%' escape '`'
			
		UNION
		
		/* ENS Messages */
		Select
			'Notification:' + Groups.Groupname + ' -> ' + [Trigger].TriggerName as [Location]
			,Msgs.ActionMsg as [Usage]
		From ENSMESSAGES as Msgs
		Join ENSGROUPS as Groups
		  on Groups.Groupofid = Msgs.Groupofid
		Join ENSACTIONS as Actions
		  on Actions.ACTIONID = Msgs.ACTIONID
		  and Actions.Groupofid = Msgs.GroupofId
		Join ENSTRIGGERS as [Trigger]
		  on [Trigger].TriggerCode = Actions.STATUSCODE
		
		Where Msgs.ActionMsg like '%`[`[' + @Property + '`]`]%' escape '`'
		
		
		UNION
		
		/*Events*/
		Select 
			'Job Event: ' + Sk.Skdname + ' -> ' + Jevents.JobName as [Location]
			,Jevents.EVDETS as [Usage]
		From JEvents as Jevents		
		Join SNAME as Sk
			on Sk.SKDID = Jevents.Skdid
		Where
			JEvents.EVDETS like '%`[`[' + @Property + '`]`]%' escape '`'

		UNION

		/* Feedback Event */
		Select 
			'Feedback Event: ' + Sk.Skdname + ' -> ' + FE.JobName as [Location]
			,FE.EventStr as [Usage]
		From FeedbackEvents as FE
		Join SNAME as Sk
			on Sk.SKDID = FE.Skdid
		Where
			FE.EventStr like '%`[`[' + @Property + '`]`]%' escape '`'

		UNION

		/* Vision Actions */
		Select 
			'Vision Action -> ' + VA.[Name] as [Location]
			,VAD.[Detail] as [Usage]
		FROM [dbo].[VisionActionDetails] AS VAD
		JOIN DBO.VisionActions AS VA
			ON VA.Id = VAD.Id
		Where VAD.Detail LIKE '%`[`[' + @Property + '`]`]%' escape '`'

		UNION ALL

		/* Service Requests */
		Select 
			'Self Service: ' + Cat.Name + ' -> ' + SR.Name as [Location]
			,CASE 
				WHEN SR.Hide_Rule like '%' + @Property + '%' THEN 'Hide Rule-' + SR.Hide_Rule
				WHEN SR.Disable_Rule like '%' + @Property + '%' THEN 'Disable Rule-' + SR.Disable_Rule
				WHEN SR.Details like '%' + @Property + '%' THEN 'Event-' + SR.Details
			 END as [Usage]
		From SERVICE_REQUEST as SR
		Join SERVICE_REQUEST_CATEGORY as Cat
		  on Cat.ServiceRequestCategoryId = SR.SERVICE_REQUEST_CATEGORY_ID
		Where
			SR.Hide_Rule like '%`[`[' + @Property + '`]`]%' escape '`'
			or SR.Disable_Rule like '%`[`[' + @Property + '`]`]%' escape '`'
			or SR.Details like '%`[`[' + @Property + '`]`]%' escape '`'
