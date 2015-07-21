angular.module 'LocalHyper.categories', []


.controller 'CategoriesCtrl', ['$scope', 'App', 'CategoriesAPI'
	, ($scope, App, CategoriesAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			parentCategories: []

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
				App.navigate 'brands', categoryID: categoryID


		$scope.$on '$ionicView.loaded', ->
			$scope.view.getCategories()

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

