angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope'
	, '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate'
	, 'User', 'Push', 'RequestAPI'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate
	, $cordovaSocialSharing, $cordovaAppRate, User, Push, RequestAPI)->

		$scope.view =
			userPopover: null
			
			userProfile: 
				display: false
				name: ''
				phone: ''

				set : ->
					user     = User.getCurrent()
					@name    = user.get 'displayName'
					@phone   = user.get 'username'
					@display = true


			init : ->
				Push.register()
				@loadPopOver()
				if User.isLoggedIn()
					@userProfile.set()
					@getOpenRequestCount()
					@getNotifications()
				$ionicSideMenuDelegate.edgeDragThreshold true

			getNotifications : ->
				RequestAPI.getNotifications()
				.then (offerIds)=>
					notifications = _.size offerIds
					App.notification.badge = notifications > 0
					App.notification.count = notifications

			getOpenRequestCount : ->
				RequestAPI.getOpenRequestCount()
				.then (data)->
					App.notification.openRequests = data.requestCount
					App.notification.offers = data.offerCount

			loadPopOver : ->
				$ionicPopover.fromTemplateUrl 'views/user-popover.html',
					scope: $scope
				.then (popover)=>
					@userPopover = popover

			onBackClick : ->
				switch App.currentState
					when 'verify-manual'
						count = if App.isAndroid() then -2 else -1
					when 'verify-success'
						forAndroid = if App.previousState is 'verify-manual' then -4 else -3
						forIOS     = -3
						count = if App.isAndroid() then forAndroid else forIOS
					else
						count = -1

				App.goBack count

			menuClose : ->
				$ionicSideMenuDelegate.toggleLeft()

			onCallUs : ->
				@menuClose()
				App.callSupport()

			onShare : ->
				@menuClose()
				subject  = "Hey, have you tried #{APP_NAME}"
				msg  = "Now get the best offers from your local sellers. Visit"
				link = "https://play.google.com/store/apps/details?id=#{PACKAGE_NAME}"
				$cordovaSocialSharing.share(msg, subject, "", link) if App.isWebView()

			onRateUs : ->
				@menuClose()
				$cordovaAppRate.promptForRating(true) if App.isWebView()

			onHelp : ->
				@menuClose()
				App.openLink HELP_URL
		

		$rootScope.$on '$user:registration:success', ->
			App.notification.icon = true
			$scope.view.userProfile.set()
			$scope.view.getOpenRequestCount()
			$scope.view.getNotifications()
			App.resize()

		$rootScope.$on 'get:open:request:count', ->
			$scope.view.getOpenRequestCount()

		$rootScope.$on 'make:request:success', ->
			$scope.view.getOpenRequestCount()

		$rootScope.$on 'update:notifications:and:open:requests', ->
			$scope.view.getNotifications()
			$scope.view.getOpenRequestCount()

		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				if App.notification.count is 0
					$scope.view.getNotifications()
				else App.notification.increment()
				$scope.view.getOpenRequestCount()
		
		$rootScope.$on 'push:notification:click', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				RequestAPI.requestDetails 'set', pushOfferId: payload.id
				App.navigate 'request-details'

			if payload.type is 'request_delivery_changed'
				RequestAPI.requestDetails 'set', pushRequestId: payload.id
				App.navigate 'request-details'
		
		$rootScope.$on 'on:session:expiry', ->
			Parse.User.logOut()
			$scope.view.userProfile.display = false
			App.notification.icon   = false
			App.notification.badge  = false
			App.resize()
]


.config ['$stateProvider', '$cordovaAppRateProvider', ($stateProvider, $cordovaAppRateProvider)->

	if ionic.Platform.isWebView()
		document.addEventListener "deviceready", ->
			customLocale = 
				title: "Rate Us"
				message: "If you enjoy using #{APP_NAME},"+
				" please take a moment to rate us."+
				" It won’t take more than a minute. Thanks for your support!"
				cancelButtonLabel: "No, Thanks"
				laterButtonLabel: "Remind Me Later"
				rateButtonLabel: "Rate Now"

			preferences = 
				language: 'en'
				appName: APP_NAME
				iosURL: PACKAGE_NAME
				androidURL: "market://details?id=#{PACKAGE_NAME}"

			$cordovaAppRateProvider.setCustomLocale customLocale
			$cordovaAppRateProvider.setPreferences preferences

	
	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
