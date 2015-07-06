angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', ($scope, App, $ionicPopover)->

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
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			cache: false
			templateUrl: 'views/main.html'
]
