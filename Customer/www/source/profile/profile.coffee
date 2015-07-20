angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$scope', ($scope)->





]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'profile',
			url: '/verify-begin'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'ProfileCtrl'
					templateUrl: 'views/profile.html'
]