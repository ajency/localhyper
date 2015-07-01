angular.module 'LocalHyper.auth'


.controller 'RegisterCtrl', ['$scope', 'AuthAPI', 'App', 'CSpinner', 'SmsAPI'
	, ($scope, AuthAPI, App, CSpinner, SmsAPI)->

		$scope.register = 
			name: 'Deepak'
			phone: 9765436351
			maxAttempts: false
		
		cordovaSmsPlugin = 
			enabled: App.isWebView() and App.isAndroid()
			src: "info.asankan.phonegap.smsplugin.smsplugin"

		register = ->
			CSpinner.show 'Authenticating...', 'Please wait...'
			AuthAPI.register $scope.register
			.then (success)->
				console.log 'Registration success'
				console.log success
			, (error)->
				console.log error
			.finally ->
				CSpinner.hide()

		verifySmsCode = (code)->
			CSpinner.show 'Verifying...', 'Please wait...'
			SmsAPI.verifySMSCode $scope.register.phone, code
			.then (data)->
				if data.verified
					register()
				else
					console.log 'Invalid verification code'
			, (error)->
				console.log 'Error verifying sms code'
			. finally ->
				CSpinner.hide()

		onSmsReceptionSuccess = (smsContent)->
			#Auto verification only for Android
			console.log smsContent
			content = smsContent.split '>'
			content = content[1]
			if s.contains(content, 'code')
				CSpinner.hide()
				code = s.words(content, ':')
				code = s.trim code[1]
				verifySmsCode code

		startSmsReception = ->
			if cordovaSmsPlugin.enabled
				smsplugin = cordova.require cordovaSmsPlugin.src
				smsplugin.startReception onSmsReceptionSuccess

		stopSmsReception = ->
			if cordovaSmsPlugin.enabled
				smsplugin = cordova.require cordovaSmsPlugin.src
				smsplugin.stopReception()

		promptForSmsCode = ->
			#Manual verification only for IOS
			if App.isIOS()
				CSpinner.hide()

		$scope.requestSMSCode = ->
			if App.isOnline()
				
				if App.isAndroid()
					CSpinner.show 'Waiting for verification code', 'Please do not close the app...'
				else if App.isIOS()
					CSpinner.show 'Sending verification code', 'Please wait...'
				
				SmsAPI.requestSMSCode $scope.register.phone
				.then (data)->
					if data.attemptsExceeded
						CSpinner.hide()
						$scope.register.maxAttempts = true
					else
						promptForSmsCode() 
				, (error)->
					CSpinner.hide()

		$scope.$on '$ionicView.enter', ->
			startSmsReception()

		$scope.$on '$ionicView.unloaded', ->
			stopSmsReception()
			
]
