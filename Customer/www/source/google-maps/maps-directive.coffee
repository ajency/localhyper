angular.module 'LocalHyper.googleMaps'


.directive 'googleMap', ['$timeout', ($timeout)->

	restrict: 'E'
	replace: true
	template: '<div data-tap-disabled="true">'
	scope:
		onCreate: '&'

	link:(scope, el, attr)->

		hideAnchorTags = ->
			$timeout ->
				$(el).find('a').parent().hide()

		initialize = ->
			mapOptions = 
				center: new google.maps.LatLng GEO_DEFAULT.lat, GEO_DEFAULT.lng
				zoom: 5
				mapTypeId: google.maps.MapTypeId.ROADMAP
				zoomControl: false
				mapTypeControl: false
				streetViewControl: false
			
			map = new google.maps.Map el[0], mapOptions
			google.maps.event.addListenerOnce map, 'idle', ->
				hideAnchorTags map
			scope.onCreate map: map

		if document.readyState is "complete"
			initialize()
		else 
			google.maps.event.addDomListener window, 'load', initialize
]


.directive 'googleMapSearch', [->

	restrict: 'A'
	replace: true
	scope:
		onPlaceChange: '&'

	link: (scope, el, attrs)->

		initialize = ->
			options = componentRestrictions: country: 'in'
			autoComplete = new google.maps.places.Autocomplete el[0], options

			google.maps.event.addListener autoComplete, 'place_changed', ->
				scope.$apply ->
					place = autoComplete.getPlace()
					scope.onPlaceChange location: place.geometry.location

		if document.readyState is "complete"
			initialize()
		else 
			google.maps.event.addDomListener window, 'load', initialize
]


.directive 'googleSearchTapDisable', ['$timeout', ($timeout)->

	link: ->
		$timeout ->
			$ '.pac-container'
				.attr 'data-tap-disabled', 'true'
				.click ->
					$('#locationSearch').blur()
		, 500
]

