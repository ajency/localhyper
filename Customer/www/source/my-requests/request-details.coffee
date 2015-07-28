angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', ($scope)->






]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'request-details',
			url: '/request-details'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/my-requests/request-details.html'
					controller: 'RequestDetailsCtrl'
]