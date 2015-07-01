angular.module 'LocalHyper.test', []


.controller 'RequestCtrl', ['$scope', '$rootScope', 'App', ($scope, $rootScope, App)->

	$scope.view = 
		one: false
		two: false
		three: false

	$rootScope.checkGlobalNotification = ->
		if !$scope.view.one and !$scope.view.two and !$scope.view.three
			$rootScope.product.globalNotification = false

	$scope.$on '$ionicView.enter', ->
		$rootScope.product.request = 'other'
		$rootScope.checkGlobalNotification()

	$scope.seeOffers = (request)->
		$rootScope.product.request = request
		App.navigate 'offers'
		$scope.view[request] = false

	$rootScope.$watch 'product.offers', (newOffers, oldOffers)->
		if (_.size(newOffers) isnt _.size(oldOffers))
			latestOffer = _.last newOffers
			if $rootScope.product.request isnt latestOffer.request
				$scope.view[latestOffer.request] = true
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'requests',
			url: '/requests'
			parent: 'main'
			views: 
				"appContent":
					controller: 'RequestCtrl'
					templateUrl: 'views/requests.html'
]

