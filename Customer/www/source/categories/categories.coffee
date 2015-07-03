angular.module 'LocalHyper.categories', []


.controller 'CategoriesCtrl', ['$scope', 'App', '$ionicPopover', 'CategoriesAPI'
	, ($scope, App, $ionicPopover, CategoriesAPI)->

		$scope.view = 
			display: 'loader'
			errorMsg: ''
			parentCategories: []
			onSuccess: (data)->
				@display = 'noError'
				@parentCategories = data
			onError: (msg)->
				@display = 'error'
				@errorMsg = msg

		$ionicPopover.fromTemplateUrl 'views/right-popover.html', scope: $scope
		.then (popover)->
			$scope.rightPopover = popover

		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()

		$scope.openRightPopover = ($event)->
			$scope.rightPopover.show $event

		getCategories = ->
			CategoriesAPI.getAll()
			.then (data)->
				console.log data
				$scope.view.onSuccess data
			, (error)->
				console.log error
				$scope.view.onError 'Could not connect to server'
				
		$scope.onTryAgain = ->
			$scope.view.display = 'loader'
			getCategories()

		if App.isOnline() then getCategories()
		else $scope.view.onError 'No internet availability'
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

