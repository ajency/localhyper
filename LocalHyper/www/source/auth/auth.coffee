angular.module 'LocalHyper.auth', []


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'login',
			url: '/login'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'LoginCtrl'
					templateUrl: 'views/auth/login.html'

		.state 'register',
			url: '/register'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'RegisterCtrl'
					templateUrl: 'views/auth/register.html'
]