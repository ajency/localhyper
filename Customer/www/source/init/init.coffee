angular.module 'LocalHyper.init', []


.controller 'InitCtrl', ['$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage'
	, ($ionicPlatform, $scope, App, Push, $rootScope, Storage)->

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
					console.log productOffers
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

			Storage.slideTutorial 'get'
			.then (value)->
				goto = if _.isNull value then "tutorial" else "categories"
				App.navigate goto, {}, {animate: false, back: false}

			Push.register()
]


.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider)->

	$stateProvider
		
		.state 'init',
			url: '/init'
			cache: false
			controller: 'InitCtrl'
			templateUrl: 'views/init/init.html'
	
	$urlRouterProvider.otherwise '/init'
]
