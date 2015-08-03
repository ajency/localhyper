angular.module 'LocalHyper.main', []


.controller 'SideMenuCtrl', ['$scope', 'App', '$ionicPopover', '$rootScope'
	, '$ionicSideMenuDelegate', 'CSpinner', '$timeout', 'Push', 'User', 'RequestsAPI'
	, ($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, CSpinner
	, $timeout, Push, User, RequestsAPI)->

		$scope.view = 
			userPopover: null

			init : ->
				Push.register()
				@loadPopOver()
				@getNotifications() if User.isLoggedIn()
				$ionicSideMenuDelegate.edgeDragThreshold true

			getNotifications : ->
				RequestsAPI.getNotifications()
				.then (requestIds)=>
					notifications = _.size requestIds
					if notifications > 0
						App.notification.badge = true
						App.notification.count = notifications

			loadPopOver : ->
				$ionicPopover.fromTemplateUrl 'views/user-popover.html',
					scope: $scope
				.then (popover)=>
					@userPopover = popover

			onBackClick : ->
				if App.currentState is 'verify-manual'
					count = if App.isAndroid() then -2 else -1
				else count = -1
				App.goBack count

			menuClose : ->
				$ionicSideMenuDelegate.toggleLeft()


		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_request'
				if App.notification.count is 0
					$scope.view.getNotifications()
				else App.notification.increment()
		
		$rootScope.$on 'on:session:expiry', ->
			CSpinner.show '', 'Your session has expired, please wait...'
			$timeout ->
				Parse.User.logOut()
				App.notification.icon = false
				App.notification.badge = false
				App.navigate 'business-details', {}, {animate: true, back: false}
				CSpinner.hide()
			, 2000
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'main',
			url: '/main'
			abstract: true
			templateUrl: 'views/main.html'
]
