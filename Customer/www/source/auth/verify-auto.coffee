angular.module 'LocalHyper.auth'


.controller 'VerifyAutoCtrl', ['$scope', 'App', 'SmsAPI', 'AuthAPI', 'User', '$timeout'
	, ($scope, App, SmsAPI, AuthAPI, User, $timeout)->

		$scope.view =
			display: 'noError'
			smsCode: ''
			errorAt: ''
			errorType: ''
			timeout: null
			smsPluginSrc: "info.asankan.phonegap.smsplugin.smsplugin"

			onError : (type, at)->
				@display = 'error'
				@errorType = type
				@errorAt = at

			startTimeout : ->
				#Wait till 40 seconds for auto verification
				@timeout = $timeout ->
					App.navigate 'verify-manual'
				, 40000

			cancelTimeout : ->
				$timeout.cancel @timeout

			requestSMSCode : ->
				@startTimeout()
				SmsAPI.requestSMSCode @user.phone
				.then (data)=>
					console.log data
					if data.attemptsExceeded
						@display = 'maxAttempts'
						@cancelTimeout() 
				, (error)=>
					@onError error, 'requestSMSCode'
					@cancelTimeout()

			startSmsReception : ->
				onSuccess = (smsContent)=>
					content = smsContent.split '>'
					content = content[1]
					if s.contains content, 'Welcome to ShopOye'
						@cancelTimeout()
						content = content.replace '[Nexmo DEMO]', ''
						code = s.words(content, 'code is')
						code = s.trim code[1]
						@smsCode = code
						@verifySmsCode()

				if App.isWebView()
					smsplugin = cordova.require @smsPluginSrc
					smsplugin.startReception onSuccess

			stopSmsReception : ->
				if App.isWebView()
					smsplugin = cordova.require @smsPluginSrc
					smsplugin.stopReception()

			verifySmsCode : ->
				SmsAPI.verifySMSCode @user.phone, @smsCode
				.then (data)=>
					@register() if data.verified
				, (error)=>
					@onError error, 'verifySmsCode'

			register : ->
				AuthAPI.register @user
				.then (success)->
					App.goBack -2
				, (error)=>
					@onError error, 'register'

			onTapToRetry : ->
				@display = 'noError'
				switch @errorAt
					when 'requestSMSCode'
						@requestSMSCode()
					when 'verifySmsCode'
						@verifySmsCode()
					when 'register'
						@register()

		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.user = User.info 'get'

		$scope.$on '$ionicView.enter', ->
			$scope.view.startSmsReception()
			$scope.view.requestSMSCode()

		$scope.$on '$ionicView.leave', ->
			$scope.view.stopSmsReception()
			$scope.view.cancelTimeout()
]
