angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate)->

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


		$rootScope.$on 'on:session:expiry', ->
			console.log 'on:session:expiry'
			Parse.User.logOut()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
