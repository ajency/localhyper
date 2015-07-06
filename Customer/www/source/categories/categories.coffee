angular.module 'LocalHyper.categories', []


.controller 'CategoriesCtrl', ['$scope', 'App', '$ionicPopover', 'CategoriesAPI'
	, ($scope, App, $ionicPopover, CategoriesAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			userPopover: null
			parentCategories: []

			loadPopOver : ->
				$ionicPopover.fromTemplateUrl 'views/right-popover.html',
					scope: $scope
				.then (popover)=>
					@userPopover = popover

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


		$scope.$on '$ionicView.loaded', ->
			$scope.view.loadPopOver()
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

