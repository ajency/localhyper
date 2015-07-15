angular.module 'LocalHyper.init', []


.controller 'InitCtrl', ['$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage'
	, ($ionicPlatform, $scope, App, Push, $rootScope, Storage)->
		
		$rootScope.$on '$cordovaPush:notificationReceived', (e, p)->
			console.log p

		$ionicPlatform.ready ->
			App.hideKeyboardAccessoryBar()
			App.setStatusBarStyle()

			Storage.slideTutorial 'get'
			.then (value)->
				goto = if _.isNull value then "tutorial" else "categories"
				App.navigate goto, {}, {animate: false, back: false}

			Push.register()
]


.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider)->

	$stateProvider
		
		.state 'init',
			url: '/init'
			cache: false
			controller: 'InitCtrl'
			templateUrl: 'views/init/init.html'
	
	$urlRouterProvider.otherwise '/init'
]
