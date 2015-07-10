getPushData = (installationId, pushOptions)->
	promise = new Parse.Promise()
	installationQuery = new Parse.Query Parse.Installation
	installationQuery.equalTo "installationId", installationId

	installationQuery.find()
	.then (installationObject)->
		if _.isEmpty(installationObject) then deviceType = 'unknown'
		else deviceType = installationObject[0].get 'deviceType'

		if deviceType.toLowerCase() is 'android'
			pushData = 
				header: pushOptions.title
				message: pushOptions.alert
				request: pushOptions.request
				otherData: pushOptions.otherData
		else
			pushData = 
				title: pushOptions.title
				alert: pushOptions.alert
				request: pushOptions.request
				badge: 'Increment'
				otherData: pushOptions.otherData

		promise.resolve pushData

	, (error)->
		promise.reject error
	
	promise

	

Parse.Cloud.job 'processNotifications', (request, response) ->
	notificationQuery = new Parse.Query("Notification") 

	# get all unporcessed notiifactions
	notificationQuery.equalTo("processed",false)
	notificationQuery.include("recipientUser")
	notificationQuery.find()
	.then (pendingNotifications) ->
		# for each pending notifications send get channel of notifications and send take action accordingly
		_.each pendingNotifications, (pendingNotification) ->
			channel = pendingNotification.get "channel"
			
			
			recipientUser = (pendingNotification.get "recipientUser").id

			switch channel
				when 'push'
					# add code to push notifcation to the user
					
					# get all unprocessed notifications i.e processed = false

					# for each of the notifications
						# get recipient user 
						# get installationId for the recipient user 
						# based on installationId query installations table and get device type 
							# based on device type generate push data
							# push data should contain message and requestId

				when 'sms'
					# add code to send sms to the user
					console.log "send sms"

		response.success("Processed pending notifications")

	, (error) ->
		response.error (error)	