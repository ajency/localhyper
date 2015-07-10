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
			console.log pendingNotification
			

			switch channel
				when 'push'
					# add code to push notifcation to the user
					console.log "push notifications"
				when 'sms'
					# add code to send sms to the user
					console.log "send sms"

		response.success("Processed pending notifications")

	, (error) ->
		response.error (error)	