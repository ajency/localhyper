angular.module 'LocalHyper.init'


.controller 'SlideTutorialCtrl', ['$scope', 'App', 'Storage', ($scope, App, Storage)->
	
	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()

	$scope.onGetStarted = ->
		Storage.slideTutorial 'set'
		.then ->
			App.navigate "departments", {}, {animate: false, back: false}

]


.config ['$stateProvider', ($stateProvider)->
	
	$stateProvider

		.state 'tutorial',
			url: '/tutorial'
			templateUrl: 'views/slide-tutorial.html'
			controller: 'SlideTutorialCtrl'
]