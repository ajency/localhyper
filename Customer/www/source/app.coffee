#App - ShopOye Customer App

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage'
	, 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products'
	, 'LocalHyper.test', 'LocalHyper.aboutUs']


.run ['$rootScope', 'App', 'Push', '$timeout', ($rootScope, App, Push, $timeout)->

	Parse.initialize APP_ID, JS_KEY

	$rootScope.App = App
	
	$rootScope.product = 
		offers: []
		globalNotification: false
		localNotification: false
		request: ''

	#User Notification Icon (Right popover)
	App.notification = icon: false

	#Hide small app logo on categories view
	App.logo = small: true
	
	$rootScope.$on '$stateChangeSuccess', (ev, to, toParams, from, fromParams)->
		$rootScope.previousState = from.name
		$rootScope.currentState = to.name
		App.previousState = from.name
		App.currentState  = to.name

		#Enable/disable menu & show/hide notification icon
		hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual']
		bool = !_.contains(hideForStates, App.currentState)
		App.menuEnabled.left  = bool
		App.notification.icon = bool

		App.logo.small = App.currentState isnt 'categories'

		# if $rootScope.currentState is 'requests'
		# 	$timeout ->
		# 		$rootScope.product.localNotification = false
		# 	, 500
]


.config ['$ionicConfigProvider', ($ionicConfigProvider)->

	$ionicConfigProvider.views.forwardCache true
	$ionicConfigProvider.backButton.previousTitleText(false).text ''
	$ionicConfigProvider.navBar.alignTitle 'center'
]

