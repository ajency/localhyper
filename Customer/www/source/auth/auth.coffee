angular.module 'LocalHyper.auth', []


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'verify-begin',
			url: '/verify-begin'
			parent: 'main'
			views: 
				"appContent":
					controller: 'VerifyBeginCtrl'
					templateUrl: 'views/auth/verify-begin.html'


		.state 'verify-auto',
			url: '/verify-auto'
			parent: 'main'
			views: 
				"appContent":
					controller: 'VerifyAutoCtrl'
					templateUrl: 'views/auth/verify-auto.html'


		.state 'verify-manual',
			url: '/verify-manual'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'VerifyManualCtrl'
					templateUrl: 'views/auth/verify-manual.html'
]