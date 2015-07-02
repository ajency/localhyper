angular.module 'LocalHyper.init'


.controller 'SlideTutorialCtrl', ['$scope', 'App', 'Storage', '$ionicSlideBoxDelegate'
	, ($scope, App, Storage, $ionicSlideBoxDelegate)->

		$scope.slide = 
			active: 0
		
		$scope.$on '$ionicView.afterEnter', ->
			$ionicSlideBoxDelegate.enableSlide false
			App.hideSplashScreen()

		$scope.onSlideChange = (index)->
			$scope.slide.active = index
			if index is 0 or index is 4
				$ionicSlideBoxDelegate.enableSlide false

		$scope.onSlideRight = ->
			slide = if $scope.slide.active isnt 0 then true else false
			$ionicSlideBoxDelegate.enableSlide slide

		$scope.onSlideLeft = ->
			slide = if $scope.slide.active isnt 4 then true else false
			$ionicSlideBoxDelegate.enableSlide slide

		$scope.onGetStarted = ->
			Storage.slideTutorial 'set'
			.then ->
				App.navigate "departments", {}, {animate: false, back: false}
]


.directive 'ajFitToScreen', ['$timeout', '$ionicSlideBoxDelegate', ($timeout, $ionicSlideBoxDelegate)->
	restrict: 'A'
	link: (scope, el, attrs)->
		
		$timeout ->
			$('.aj-slide-img').css
				width: $(window).width()
				height: $(window).height()
]


.config ['$stateProvider', ($stateProvider)->
	
	$stateProvider

		.state 'tutorial',
			url: '/tutorial'
			templateUrl: 'views/init/slide-tutorial.html'
			controller: 'SlideTutorialCtrl'
]