angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', ($scope, App)->

	$scope.view = 

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
