angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope'
	, '$ionicSideMenuDelegate', 'CSpinner', '$timeout'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, CSpinner, $timeout)->

		$scope.view = 
			userPopover: null

			init : ->
				@loadPopOver()
				$ionicSideMenuDelegate.edgeDragThreshold true

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


		$rootScope.$on 'on:new:request', ->
			App.notification.increment()

		$rootScope.$on 'on:session:expiry', ->
			CSpinner.show '', 'Your session has expired, please wait...'
			$timeout ->
				Parse.User.logOut()
				App.navigate 'business-details', {}, {animate: true, back: false}
				CSpinner.hide()
			, 2000
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
