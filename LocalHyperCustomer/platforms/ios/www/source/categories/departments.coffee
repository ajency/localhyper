angular.module 'LocalHyper.categories'


.controller 'DepartmentsCtrl', ['$scope', 'App', '$ionicPopover', ($scope, App, $ionicPopover)->

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

		.state 'departments',
			url: '/departments'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/categories/departments.html'
					controller: 'DepartmentsCtrl'

]