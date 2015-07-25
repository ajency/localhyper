angular.module 'LocalHyper.products'


.controller 'MakeRequestCtrl', ['$scope', 'App'
	, ($scope, App)->

		$scope.view =
			a:''

			logoAndNotif :
				get : ->
					@smallLogo = App.logo.small
					@notifIcon = App.notification.icon
				reset : ->
					App.logo.small = @smallLogo
					App.notification.icon = @notifIcon
				hide : ->
					@get()
					App.logo.small = false
					App.notification.icon = false

			init : ->





		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.logoAndNotif.hide()

		$scope.$on '$ionicView.beforeLeave', ->
			$scope.view.logoAndNotif.reset()
]



.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'make-request',
			url: '/make-request'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/make-request.html'
					controller: 'MakeRequestCtrl'
]