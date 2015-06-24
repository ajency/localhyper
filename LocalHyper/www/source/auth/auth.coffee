angular.module 'LocalHyper.auth', []


.controller 'StartCtrl', ['$scope', 'App', ($scope, App)->
	
	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'auth',
			url: '/auth'
			templateUrl: 'views/auth/auth.html'

		.state 'start',
			url: '/start'
			parent: 'auth'
			views: 
				"authContent":
					templateUrl: 'views/auth/start.html'
					controller: 'StartCtrl'

		.state 'login',
			url: '/login'
			parent: 'auth'
			cache: false
			views: 
				"authContent":
					controller: 'LoginCtrl'
					templateUrl: 'views/auth/login.html'

		.state 'sign-up',
			url: '/signup'
			parent: 'auth'
			cache: false
			views: 
				"authContent":
					controller: 'SignUpCtrl'
					templateUrl: 'views/auth/sign-up.html'
]