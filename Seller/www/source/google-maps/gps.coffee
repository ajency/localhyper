angular.module 'LocalHyper.googleMaps'


.factory 'GPS', ['$q', '$cordovaGeolocation', 'App', ($q, $cordovaGeolocation, App)->

	GPS = {}

	GPS.isLocationEnabled = ->
		defer = $q.defer()
		if App.isWebView()
			cordova.plugins.diagnostic.isLocationEnabled (enabled)->
				defer.resolve enabled
			, (error)->
				defer.reject error
		else 
			defer.resolve true
			
		defer.promise

	GPS.switchToLocationSettings = ->
		if App.isWebView() and App.isAndroid()
			cordova.plugins.diagnostic.switchToLocationSettings()

	GPS.getCurrentLocation = ->
		defer = $q.defer()
		posOptions = 
			maximumAge:0
			timeout: 15000
			enableHighAccuracy: true
				
		$cordovaGeolocation.getCurrentPosition posOptions
		.then (position)->
			loc = 
				lat: position.coords.latitude
				long: position.coords.longitude
			defer.resolve loc
		, (error)->
			defer.reject error

		defer.promise

	GPS
]