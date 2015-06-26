angular.module 'LocalHyper.common', []


.factory 'App', ['$cordovaSplashscreen', '$state', '$ionicHistory', '$ionicSideMenuDelegate'
	, '$window', '$cordovaStatusbar', '$cordovaKeyboard'
	, ($cordovaSplashscreen, $state, $ionicHistory, $ionicSideMenuDelegate, $window
	, $cordovaStatusbar, $cordovaKeyboard)->

		App = 

			start: true

			validateEmail: /^[a-z]+[a-z0-9._]+@[a-z]+\.[a-z.]{2,5}$/

			menuEnabled : left: false, right: false

			isAndroid : ->
				ionic.Platform.isAndroid()

			isIOS : ->
				ionic.Platform.isIOS()

			isWebView : ->
				ionic.Platform.isWebView()

			deviceUUID : ->
				if @isWebView() then device.uuid else 'DUMMYUUID'

			hideSplashScreen : ->
				$cordovaSplashscreen.hide() if @isWebView()

			hideKeyboardAccessoryBar : ->
				if $window.cordova && $window.cordova.plugins.Keyboard
					$cordovaKeyboard.hideAccessoryBar true

			setStatusBarStyle : ->
				#styles: Default : 0, LightContent: 1, BlackTranslucent: 2, BlackOpaque: 3
				$cordovaStatusbar.style(0) if $window.StatusBar

			noTapScroll : ->
				#Enable scroll to top on header click only for iOS
				"#{!@isIOS()}"

			navigate : (state, params={}, opts={})->
				if !_.isEmpty(opts)
					animate = if _.has(opts, 'animate') then opts.animate else false
					back    = if _.has(opts, 'back')    then opts.back    else false
					$ionicHistory.nextViewOptions
						disableAnimate: !animate
						disableBack   : !back
		
				$state.go state, params

			goBack : ->
				$ionicHistory.goBack()

			dragContent : (bool)->
				$ionicSideMenuDelegate.canDragContent bool

]

