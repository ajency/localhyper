angular.module 'LocalHyper.requests', []


.controller 'RequestCtrl', ['$scope', 'App', ($scope, App)->


	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'requests',
			url: '/requests'
			parent: 'main'
			views: 
				"appContent":
					controller: 'RequestCtrl'
					templateUrl: 'views/requests/requests.html'
]