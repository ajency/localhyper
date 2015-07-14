angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', '$cordovaSocialSharing', '$cordovaAppRate'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, $cordovaSocialSharing, $cordovaAppRate)->

		$scope.view =
			

			userPopover: null

			init : ->
				@loadPopOver()

			loadPopOver : ->
				$ionicPopover.fromTemplateUrl 'views/right-popover.html',
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

			call : ->
				call = "tel:9049678054"
				document.location.href = call

			shareAnywhere : ->
				 sub  = "Hey, have you tried Shopoye."
				 msg = " You can get the best offers from your local sellers just on one click. I am sure you will like it."
				 link = "https://play.google.com/store/apps/details?id=com.facebook.katana&hl=en"
				 image = ""
				 $cordovaSocialSharing.share(msg, sub, "", link)

			rateUs : ->
				document.addEventListener "deviceready",()->
					$cordovaAppRate.promptForRating(true).then (result)->




		$rootScope.$on 'on:session:expiry', ->
			console.log 'on:session:expiry'
			Parse.User.logOut()
]


.config ['$stateProvider', '$cordovaAppRateProvider', ($stateProvider ,$cordovaAppRateProvider)->

	document.addEventListener "deviceready",()->
		AppRate.preferences.useLanguage = 'en';
		popupInfo = {};
		popupInfo.title = "Rate Us";
		popupInfo.message = "In Love with the app ? Give us five star!";
		popupInfo.cancelButtonLabel = "No, thanks";
		popupInfo.laterButtonLabel = "Remind Me Later";
		popupInfo.rateButtonLabel = "Rate Now";
		AppRate.preferences.customLocale = popupInfo;
		AppRate.preferences.usesUntilPrompt = 1
		AppRate.preferences.openStoreInApp = false;		
		AppRate.preferences.storeAppURL.ios = '849930087';
		AppRate.preferences.storeAppURL.android = 'market://details?id=com.jabong.android';

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
