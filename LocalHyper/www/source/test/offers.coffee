angular.module 'LocalHyper.test'


.controller 'OffersCtrl', ['$scope', '$rootScope', ($scope, $rootScope)->

	$scope.view = 
		offers: []

	$rootScope.checkGlobalNotification()

	unbindOffersWatch = $rootScope.$watch 'product.offers', (newOffers)->
		if !_.isEmpty newOffers
			offers = _.filter newOffers, (offer)-> offer.request is $rootScope.product.request
			$scope.view.offers = offers

	$scope.$on '$ionicView.unloaded', ->
		unbindOffersWatch()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'offers',
			url: '/offers'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'OffersCtrl'
					templateUrl: 'views/offers.html'
]

