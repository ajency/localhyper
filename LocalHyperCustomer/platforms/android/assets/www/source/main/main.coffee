angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', ($scope)->





]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
