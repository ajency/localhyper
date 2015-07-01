angular.module 'LocalHyper.auth'


.controller 'RegisterCtrl', ['$scope', 'AuthAPI', 'App', 'CSpinner', 'SmsAPI', 'CSms'
	, ($scope, AuthAPI, App, CSpinner, SmsAPI, CSms)->

		$scope.register = 
			name: 'Deepak'
			phone: 9765436351
			maxAttempts: false

		# AuthAPI.register $scope.register
		# .then (success)->
		# 	console.log success
		# , (error)->
		# 	console.log error

		showPlatformSpinner = ->
			if App.isAndroid()
				CSpinner.show 'Waiting for verification code', 'Please do not close the app...'
			else if App.isIOS()
				CSpinner.show 'Sending verification code', 'Please wait...'

		handleForPlatform = ->


		$scope.requestSMSCode = ->
			if App.isOnline()
				showPlatformSpinner()
				SmsAPI.requestSMSCode $scope.register.phone
				.then (data)->
					if data.attemptsExceeded 
						$scope.register.maxAttempts = true
					else
						handleForPlatform()
				, (error)->
					console.log 'onError'
					console.log error
					CSpinner.hide()
]
