angular.module 'LocalHyper.auth', []


.controller 'StartCtrl', ['$scope', 'App', ($scope, App)->
	
	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'start',
			url: '/start'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/auth/start.html'
					controller: 'StartCtrl'

		.state 'login',
			url: '/login'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'LoginCtrl'
					templateUrl: 'views/auth/login.html'

		.state 'sign-up',
			url: '/signup'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'SignUpCtrl'
					templateUrl: 'views/auth/sign-up.html'
]