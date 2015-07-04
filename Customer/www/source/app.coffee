#App - ShopOye Customer App

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage'
	, 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products', 'LocalHyper.test']


.run ['$rootScope', 'App', 'Push', '$timeout', ($rootScope, App, Push, $timeout)->

	Parse.initialize APP_ID, JS_KEY

	$rootScope.App = App
	
	$rootScope.product = 
		offers: []
		globalNotification: false
		localNotification: false
		request: ''
	
	$rootScope.$on '$stateChangeSuccess', (ev, to, toParams, from, fromParams)->
		$rootScope.previousState = from.name
		$rootScope.currentState = to.name

		#Enable/disable menu
		hideMenuStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual']
		if _.contains hideMenuStates, $rootScope.currentState
			App.menuEnabled.left = false
		else App.menuEnabled.left = true

		if $rootScope.currentState is 'requests'
			$timeout ->
				$rootScope.product.localNotification = false
			, 500
]


.config ['$ionicConfigProvider', ($ionicConfigProvider)->

	$ionicConfigProvider.views.forwardCache true
	$ionicConfigProvider.backButton.previousTitleText(false).text ''
	$ionicConfigProvider.navBar.alignTitle 'center'
]

