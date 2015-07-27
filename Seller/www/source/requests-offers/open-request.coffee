angular.module 'LocalHyper.requestsProducts', []


.controller 'OpenRequestCtrl', ['$scope', 'App'
	, ($scope, App)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			parentCategories: []

			init : ->
				@getCategories()

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


		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]



