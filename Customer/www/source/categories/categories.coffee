angular.module 'LocalHyper.categories', []


.controller 'CategoriesCtrl', ['$scope', 'App', 'CategoriesAPI', 'Push'
	, 'RequestAPI', '$rootScope'
	, ($scope, App, CategoriesAPI, Push, RequestAPI, $rootScope)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			parentCategories: []

			init : ->
				Push.register()
				@getNotifications()
				@getCategories()

			getNotifications : ->
				RequestAPI.getNotifications()
				.then (offerIds)=>
					notifications = _.size offerIds
					if notifications > 0
						App.notification.badge = true
						App.notification.count = notifications

			getCategories : ->
				CategoriesAPI.getAll()
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error

			onSuccess : (data)->
				@display = 'noError'
				@parentCategories = data
			
			onError: (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getCategories()

			onSubcategoryClick : (children, categoryID)->
				CategoriesAPI.subCategories 'set', children
				App.navigate 'products', categoryID: categoryID


		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				$scope.view.getNotifications()

		$rootScope.$on 'push:notification:click', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				RequestAPI.requestDetails 'set', pushOfferId: payload.id
				App.navigate 'request-details'

		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'categories',
			url: '/categories'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/categories/categories.html'
					controller: 'CategoriesCtrl'
]

