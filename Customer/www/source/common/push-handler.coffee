angular.module 'LocalHyper.common'


.factory 'Push', ['App', '$cordovaPush', (App, $cordovaPush)->

	Push = {}

	Push.register = ->
		androidConfig = "senderID": "DUMMY_SENDER_ID"
		iosConfig     = "badge": true, "sound": true, "alert": true

		if App.isWebView()
			config = if App.isIOS() then iosConfig else androidConfig

			$cordovaPush.register config
			.then (success)->
				console.log 'Push Registration Success'
			, (error)->
				console.log 'Push Registration Error'

	Push.getPayload = (p)->
		payload = {}
		if App.isAndroid()
			if p.event is 'message'
				payload = p.payload.data
				payload.foreground = p.foreground
				payload.coldstart = p.coldstart if _.has(p, 'coldstart')

		if App.isIOS()
			payload = p
			foreground = if p.foreground is "1" then true else false
			payload.foreground = foreground

		payload

	Push.handlePayload = (event, payload)->
		console.log 'Notification received'
		console.log payload

	Push
]