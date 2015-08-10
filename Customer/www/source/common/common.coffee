angular.module 'LocalHyper.common', []


.factory 'App', ['$cordovaSplashscreen', '$state', '$ionicHistory', '$ionicSideMenuDelegate'
	, '$window', '$cordovaStatusbar', '$cordovaKeyboard', '$cordovaNetwork', '$timeout', '$q'
	, '$ionicScrollDelegate', '$cordovaInAppBrowser'
	, ($cordovaSplashscreen, $state, $ionicHistory, $ionicSideMenuDelegate, $window, $cordovaStatusbar
	, $cordovaKeyboard, $cordovaNetwork, $timeout, $q, $ionicScrollDelegate, $cordovaInAppBrowser)->

		App = 

			start: true
			validateEmail: /^[a-z]+[a-z0-9._]+@[a-z]+\.[a-z.]{2,5}$/
			onlyNumbers: /^\d+$/
			menuEnabled : left: false, right: false
			previousState: ''
			currentState: ''

			isAndroid : ->
				ionic.Platform.isAndroid()

			isIOS : ->
				ionic.Platform.isIOS()

			isWebView : ->
				ionic.Platform.isWebView()

			isOnline : ->
				if @isWebView() then $cordovaNetwork.isOnline()
				else navigator.onLine

			deviceUUID : ->
				if @isWebView() then device.uuid else 'DUMMYUUID'

			hideSplashScreen : ->
				if @isWebView()
					$timeout -> 
						$cordovaSplashscreen.hide()
					, 500

			hideKeyboardAccessoryBar : ->
				if $window.cordova && $window.cordova.plugins.Keyboard
					$cordovaKeyboard.hideAccessoryBar true

			setStatusBarStyle : ->
				#styles: Default : 0, LightContent: 1, BlackTranslucent: 2, BlackOpaque: 3
				$cordovaStatusbar.style(0) if $window.StatusBar

			closeKeyboard : ->
				$cordovaKeyboard.close() if @isWebView()

			noTapScroll : ->
				#Enable scroll to top on header click only for iOS
				!@isIOS()

			navigate : (state, params={}, opts={})->
				if !_.isEmpty(opts)
					animate = if _.has(opts, 'animate') then opts.animate else false
					back    = if _.has(opts, 'back')    then opts.back    else false
					$ionicHistory.nextViewOptions
						disableAnimate: !animate
						disableBack   : !back
		
				$state.go state, params

			goBack : (count)->
				$ionicHistory.goBack count

			dragContent : (bool)->
				$ionicSideMenuDelegate.canDragContent bool

			resize : ->
				$ionicScrollDelegate.resize()

			scrollTop : ->
				$ionicScrollDelegate.scrollTop true

			scrollBottom : ->
				$ionicScrollDelegate.scrollBottom true

			toINR : (number)->
				if !_.isUndefined number
					number = number.toString()
					number.replace /(\d)(?=(\d\d)+\d$)/g, "$1,"
				else ''

			humanize : (str)->
				s.humanize str

			openLink : (url)->
				options = location: 'yes'
				$cordovaInAppBrowser.open url, '_system', options

			callSupport : ->
				telURI = "tel:#{SUPPORT_NUMBER}"
				document.location.href = telURI

			getInstallationId : ->
				defer = $q.defer()
				if @isWebView()
					parsePlugin.getInstallationId (installationId)-> 
						defer.resolve installationId
					, (error) ->
						defer.reject error
				else
					defer.resolve 'DUMMY_INSTALLATION_ID'

				defer.promise
]

