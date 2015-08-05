angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope'
	, '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate'
	, 'User', 'Push', 'RequestAPI'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate
	, $cordovaSocialSharing, $cordovaAppRate, User, Push, RequestAPI)->

		$scope.view =
			userPopover: null

			init : ->
				Push.register()
				@loadPopOver()
				@getNotifications() if User.isLoggedIn()
				$ionicSideMenuDelegate.edgeDragThreshold true

			getNotifications : ->
				RequestAPI.getNotifications()
				.then (offerIds)=>
					notifications = _.size offerIds
					if notifications > 0
						App.notification.badge = true
						App.notification.count = notifications

			loadPopOver : ->
				$ionicPopover.fromTemplateUrl 'views/user-popover.html',
					scope: $scope
				.then (popover)=>
					@userPopover = popover

			onBackClick : ->
				if App.currentState is 'verify-manual'
					count = if App.isAndroid() then -2 else -1
				else count = -1
				App.goBack count

			menuClose : ->
				$ionicSideMenuDelegate.toggleLeft()

			onCallUs : ->
				@menuClose()
				telURI = "tel:#{SUPPORT_NUMBER}"
				document.location.href = telURI

			onShare : ->
				@menuClose()
				subject  = "Hey, have you tried #{APP_NAME}"
				msg  = "Now get the best offers from your local sellers. Visit"
				link = "https://play.google.com/store/apps/details?id=#{PACKAGE_NAME}"
				$cordovaSocialSharing.share(msg, subject, "", link) if App.isWebView()

			onRateUs : ->
				@menuClose()
				$cordovaAppRate.promptForRating(true) if App.isWebView()
		

		$rootScope.$on '$user:registration:success', ->
			App.notification.icon = true
			$scope.view.getNotifications()

		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				if App.notification.count is 0
					$scope.view.getNotifications()
				else App.notification.increment()
		
		$rootScope.$on 'push:notification:click', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				RequestAPI.requestDetails 'set', pushOfferId: payload.id
				App.navigate 'request-details'
		
		$rootScope.$on 'on:session:expiry', ->
			Parse.User.logOut()
			App.notification.icon = false
			App.notification.badge = false
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
