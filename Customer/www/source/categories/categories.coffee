angular.module 'LocalHyper.categories', []


.controller 'CategoriesCtrl', ['$scope', 'App', '$ionicPopover', ($scope, App, $ionicPopover)->

	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()

	$ionicPopover.fromTemplateUrl 'views/right-popover.html',
		scope: $scope
	.then (popover)->
		$scope.rightPopover = popover

	$scope.openRightPopover = ($event)->
		$scope.rightPopover.show $event

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