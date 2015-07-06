angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', ($scope)->





]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			cache: false
			templateUrl: 'views/main.html'
]
