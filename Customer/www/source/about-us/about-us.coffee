angular.module 'LocalHyper.aboutUs', []


.controller 'AboutUsCtrl', ['$scope', ($scope)->



]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'about-us',
			url: '/about-us'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'AboutUsCtrl'
					templateUrl: 'views/about-us.html'
]