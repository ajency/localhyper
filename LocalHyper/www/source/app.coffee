#App - LocalHyper

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.init'
	, 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.products', 'LocalHyper.test']


.run ['$rootScope', 'App', 'Push', '$timeout', ($rootScope, App, Push, $timeout)->

	Parse.initialize 'bv6HajGGe6Ver72lkjIiV0jYbJL5ll0tTWNG3obY', 'uxqIu6soZAOzPXHuLQDhOwBuA3KWAAuuK75l1Z3x'

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
		hideMenuStates = ['start', 'login', 'sign-up']
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
]

