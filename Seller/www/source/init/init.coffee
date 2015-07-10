angular.module 'LocalHyper.init', []


.controller 'InitCtrl', ['$ionicPlatform', '$scope', 'App', 'Push', '$rootScope', 'Storage', 'User'
	, ($ionicPlatform, $scope, App, Push, $rootScope, Storage, User)->
		
		$rootScope.$on '$cordovaPush:notificationReceived', (e, p)->
			console.log p

		$ionicPlatform.ready ->
			App.hideKeyboardAccessoryBar()
			App.setStatusBarStyle()

			Storage.slideTutorial 'get'
			.then (value)->
				if _.isNull value then goto = "tutorial" 
				else if User.isLoggedIn() then goto = "new-requests" 
				else goto = 'business-details'
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
