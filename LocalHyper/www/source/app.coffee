#App - LocalHyper

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.auth', 'LocalHyper.test']


.run ['$rootScope', 'App', 'Push', '$timeout', ($rootScope, App, Push, $timeout)->

	Parse.initialize 'bv6HajGGe6Ver72lkjIiV0jYbJL5ll0tTWNG3obY', 'uxqIu6soZAOzPXHuLQDhOwBuA3KWAAuuK75l1Z3x'

	$rootScope.App = App
	$rootScope.product = 
		offers: []
		globalNotification: false
		localNotification: false
		request: ''

	$rootScope.$on '$stateChangeSuccess', (ev, to, toParams, from, fromParams)->
		$rootScope.previousState = from.name
		$rootScope.currentState = to.name

		if $rootScope.currentState is 'requests'
			$timeout ->
				$rootScope.product.localNotification = false
			, 500
]


.controller 'InitCtrl', ['$ionicPlatform', '$scope', 'App', 'Push', '$rootScope'
	, ($ionicPlatform, $scope, App, Push, $rootScope)->

		getOffers = ->
			Offers = Parse.Object.extend "Offers"
			query = new Parse.Query(Offers)

			productOffers = $rootScope.product.offers
			if !_.isEmpty productOffers
				ids = _.pluck productOffers, 'id'
				query.notContainedIn "objectId", ids

			query.find()
			.then (offers)->
				_.each offers, (offer, i)->
					obj = 
						id: offer.id
						request: offer.get 'request'
						location: offer.get 'location'
						price: offer.get 'price'
						deliveryTime: offer.get 'deliveryTime'
						updatedAt: offer.get 'updatedAt'

					productOffers = productOffers.concat obj
				
				$scope.$apply ->
					$rootScope.product.offers = productOffers

		getOffers()
		
		$rootScope.$on '$cordovaPush:notificationReceived', (e, p)->
			payload = Push.getPayload p
			console.log payload
			if !_.has(payload, 'coldstart')
				getOffers()

			if _.has(payload, 'coldstart') and payload.coldstart is true
				getOffers()

		$rootScope.$watch 'product.offers', (newOffers, oldOffers)->
			if (_.size(newOffers) isnt _.size(oldOffers)) and !$rootScope.App.start
				if $rootScope.currentState is 'offers'
					latestOffer = _.last newOffers
					if latestOffer.request isnt $rootScope.product.request
						$rootScope.product.globalNotification = true
					else if latestOffer.request is $rootScope.product.request
						$rootScope.product.localNotification = true
				else
					$rootScope.product.globalNotification = true

			$rootScope.App.start = false

		$ionicPlatform.ready ->
			App.hideKeyboardAccessoryBar()
			App.setStatusBarStyle()
			App.navigate 'start', {}, {animate: false, back: false}

			Push.register()
]


.config ['$stateProvider', '$ionicConfigProvider', '$urlRouterProvider'
	, ($stateProvider, $ionicConfigProvider, $urlRouterProvider)->

		$ionicConfigProvider.views.forwardCache true
		$ionicConfigProvider.backButton.previousTitleText(false).text ''

		$stateProvider
			
			.state 'init',
				url: '/init'
				controller: 'InitCtrl'
				templateUrl: 'views/init.html'
		
		$urlRouterProvider.otherwise '/init'
]

