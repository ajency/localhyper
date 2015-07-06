angular.module 'LocalHyper.init'


.controller 'SlideTutorialCtrl', ['$scope', 'App', 'Storage', '$ionicSlideBoxDelegate'
	, ($scope, App, Storage, $ionicSlideBoxDelegate)->

		$scope.view = 
			activeSlide: 0

			slide : (bool)->
				$ionicSlideBoxDelegate.enableSlide bool

			onGetStarted : ->
				Storage.slideTutorial 'set'
				.then ->
					App.navigate "categories", {}, {animate: true, back: false}

			onSlideChange : (index)->
				@activeSlide = index
				if index is 0 or index is 4
					@slide false

			onSlideRight : ->
				bool = if @activeSlide isnt 0 then true else false
				@slide bool

			onSlideLeft : ->
				bool = if @activeSlide isnt 4 then true else false
				@slide bool

		
		$scope.$on '$ionicView.afterEnter', ->
			$scope.view.slide false
			App.hideSplashScreen()
]


.directive 'ajFitToScreen', ['$timeout', ($timeout)->
	
	restrict: 'A'
	link: (scope, el, attrs)->
		
		$timeout ->
			$('.aj-slide-img').css
				width : $(window).width()
				height: $(window).height()
]


.config ['$stateProvider', ($stateProvider)->
	
	$stateProvider

		.state 'tutorial',
			url: '/tutorial'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/init/slide-tutorial.html'
					controller: 'SlideTutorialCtrl'
]

