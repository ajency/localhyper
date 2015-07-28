#App - ShopOye Customer App

angular.module 'LocalHyper', ['ionic', 'ngCordova'
	, 'LocalHyper.common', 'LocalHyper.init', 'LocalHyper.storage'
	, 'LocalHyper.auth', 'LocalHyper.main', 'LocalHyper.categories', 'LocalHyper.products'
	, 'LocalHyper.aboutUs', 'LocalHyper.googleMaps','LocalHyper.suggestProduct', 'LocalHyper.profile'
	, 'LocalHyper.myRequests', 'LocalHyper.myRequests']


.run ['$rootScope', 'App', 'GoogleMaps', 'User', ($rootScope, App, GoogleMaps, User)->

	Parse.initialize APP_ID, JS_KEY
	$rootScope.App = App
	GoogleMaps.loadScript()

	#User Notification Icon (Right popover)
	App.notification = 
		icon: User.isLoggedIn()
		badge: false
		count: 0
		increment : ->
			@badge = true
			@count = @count + 1
		decrement : ->
			@count = @count - 1
			@badge = false if @count is 0

	$rootScope.$on '$user:registration:success', ->
		App.notification.icon = true

	#Hide small app logo on categories view
	App.logo = small: true
	
	$rootScope.$on '$stateChangeSuccess', (ev, to, toParams, from, fromParams)->
		App.previousState = from.name
		App.currentState  = to.name

		#Enable/disable menu & show/hide notification icon
		hideForStates = ['tutorial', 'verify-begin', 'verify-auto', 'verify-manual']
		bool = !_.contains(hideForStates, App.currentState)
		App.menuEnabled.left  = bool
]


.config ['$ionicConfigProvider', ($ionicConfigProvider)->

	$ionicConfigProvider.views.forwardCache true
	$ionicConfigProvider.backButton.previousTitleText(false).text ''
	$ionicConfigProvider.navBar.alignTitle 'center'
]

