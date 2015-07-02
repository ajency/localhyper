angular.module 'LocalHyper.auth'


.controller 'VerifyManualCtrl', ['$scope', '$rootScope', 'CToast', 'App', 'SmsAPI', 'AuthAPI', 'CSpinner'
	, ($scope, $rootScope, CToast, App, SmsAPI, AuthAPI, CSpinner)->

		$scope.view = 
			display: 'noError'

		$scope.sms = 
			code: ''
			errorAt: ''

		register = ->
			AuthAPI.register $rootScope.user
			.then (success)->
				App.navigate 'categories', {}, {animate: false, back: false}
			, (error)->
				$scope.sms.errorAt = 'register'
				$scope.view.display = 'error'
			.finally ->
				CSpinner.hide()

		verifySmsCode = ->
			CSpinner.show '', 'Please wait...'
			SmsAPI.verifySMSCode $rootScope.user.phone, $scope.sms.code
			.then (data)->
				if data.verified
					register()
				else 
					CSpinner.hide()
					CToast.show 'Incorrect verification code'
			, (error)->
				CSpinner.hide()
				$scope.sms.errorAt = 'verifySmsCode'
				$scope.view.display = 'error'

		requestSMSCode = ->
			CSpinner.show '', 'Please wait...'
			SmsAPI.requestSMSCode $rootScope.user.phone
			.then (data)->
				if data.attemptsExceeded
					$scope.view.display = 'maxAttempts'
			, (error)->
				$scope.sms.errorAt = 'requestSMSCode'
				$scope.view.display = 'error'
			.finally ->
				CSpinner.hide()

		$scope.onNext = ->
			code  = $scope.sms.code
			if code is '' or _.isUndefined(code)
				CToast.show 'Please enter verification code'
			else
				if App.isOnline() then verifySmsCode()
				else CToast.show 'No internet availability'

		$scope.onResendCode = ->
			requestSMSCode()

		$scope.$on '$ionicView.enter', ->
			if App.isIOS() then requestSMSCode()

		$scope.onTryAgain = ->
			$scope.view.display = 'noError'
			switch $scope.sms.errorAt
				when 'requestSMSCode'
					requestSMSCode()
				when 'verifySmsCode'
					verifySmsCode()
				when 'register'
					register()
]
