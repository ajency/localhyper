angular.module 'LocalHyper.myProducts', []


.directive 'ajRemoveBoxShadow', ['$timeout', ($timeout)->

	restrict: 'A'
	link: (scope, el, attrs)->
		$timeout ->
			$('.bar-header').removeClass 'bar-light'
]


.directive 'ajAddBoxShadow', ['$timeout', ($timeout)->

	restrict: 'A'
	link: (scope, el, attrs)->
		$timeout ->
			$('.bar-header').addClass 'bar-light'
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'tabs',
			url: "/tab"
			abstract: true
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/my-products/tabs.html'

		.state 'open-requests',
			url: '/open-requests'
			parent: 'tabs'
			views: 
				"openRequestsTab":
					controller: 'OpenRequestCtrl'
					templateUrl: 'views/my-products/open-requests.html'

		.state 'requests-history',
			url: '/requests-history'
			parent: 'tabs'
			views: 
				"productHistoryTab":
					controller: 'ProductHistoryCtrl'
					templateUrl: 'views/my-products/product-history.html'

		
]






