angular.module 'LocalHyper.googleMaps'


.factory 'GPS', ['$q', '$cordovaGeolocation', ($q,$cordovaGeolocation)->

	GPS = {}

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