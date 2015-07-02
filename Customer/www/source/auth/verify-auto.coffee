angular.module 'LocalHyper.auth'


.controller 'VerifyAutoCtrl', ['$scope', '$rootScope', 'App', 'SmsAPI', 'AuthAPI'
	, ($scope, $rootScope, App, SmsAPI, AuthAPI)->

		$scope.view = display: 'noError'

		sms = 
			code: ''
			errorAt: ''

		cordovaSmsPlugin = 
			enabled: App.isWebView() and App.isAndroid()
			src: "info.asankan.phonegap.smsplugin.smsplugin"

		register = ->
			AuthAPI.register $rootScope.user
			.then (success)->
				App.navigate 'departments', {}, {animate: false, back: false}
			, (error)->
				sms.errorAt = 'register'
				$scope.view.display = 'error'

		verifySmsCode = (code)->
			SmsAPI.verifySMSCode $rootScope.user.phone, code
			.then (data)->
				if data.verified
					register()
			, (error)->
				sms.errorAt = 'verifySmsCode'
				$scope.view.display = 'error'

		onSmsReceptionSuccess = (smsContent)->
			console.log smsContent
			content = smsContent.split '>'
			content = content[1]
			if s.contains(content, 'code')
				code = s.words(content, ':')
				code = s.trim code[1]
				sms.code = code
				verifySmsCode code

		startSmsReception = ->
			if cordovaSmsPlugin.enabled
				smsplugin = cordova.require cordovaSmsPlugin.src
				smsplugin.startReception onSmsReceptionSuccess

		stopSmsReception = ->
			if cordovaSmsPlugin.enabled
				smsplugin = cordova.require cordovaSmsPlugin.src
				smsplugin.stopReception()

		requestSMSCode = ->
			SmsAPI.requestSMSCode $rootScope.user.phone
			.then (data)->
				console.log data
				if data.attemptsExceeded
					$scope.view.display = 'maxAttempts'
			, (error)->
				sms.errorAt = 'requestSMSCode'
				$scope.view.display = 'error'

		$scope.onTryAgain = ->
			$scope.view.display = 'noError'
			switch sms.errorAt
				when 'requestSMSCode'
					requestSMSCode()
				when 'verifySmsCode'
					verifySmsCode sms.code
				when 'register'
					register()

		requestSMSCode()

		$scope.$on '$ionicView.enter', ->
			startSmsReception()

		$scope.$on '$ionicView.leave', ->
			stopSmsReception()
]
