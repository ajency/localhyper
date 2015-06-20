#App - LocalHyper

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.auth']


.run ['$rootScope', 'App', ($rootScope, App)->

	$rootScope.App = App
]


.controller 'InitCtrl', ['$ionicPlatform', '$scope', 'App'
	, ($ionicPlatform, $scope, App)->

		$ionicPlatform.ready ->
			App.hideKeyboardAccessoryBar()
			App.setStatusBarStyle()
			App.navigate 'start', {}, {animate: false, back: false}
]


.config ['$stateProvider', '$ionicConfigProvider', '$urlRouterProvider'
	, ($stateProvider, $ionicConfigProvider, $urlRouterProvider)->

		$ionicConfigProvider.views.forwardCache true
		$ionicConfigProvider.backButton.previousTitleText(false).text ''

		$stateProvider
			
			.state 'init',
				url: '/init'
				controller: 'InitCtrl'
				templateUrl: 'views/init.html'
		
		$urlRouterProvider.otherwise '/init'
]