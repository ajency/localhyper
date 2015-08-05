angular.module 'LocalHyper.aboutUs', []


.controller 'AboutUsCtrl', ['$scope', '$cordovaAppVersion', 'App'
	, ($scope, $cordovaAppVersion, App)->

		$scope.view = 
			appVersion: 'Loading...'

			init : ->
				if App.isWebView()
					$cordovaAppVersion.getAppVersion()
					.then (version)=>
						@appVersion = version

		
		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'about-us',
			url: '/about-us'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'AboutUsCtrl'
					templateUrl: 'views/about-us.html'
]