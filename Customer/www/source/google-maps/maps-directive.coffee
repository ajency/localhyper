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

	link: (scope, el, attrs)->

		initialize = ->
			input = document.getElementById 'search'
			options = 
				componentRestrictions: country: 'in'

			autoComplete = new google.maps.places.Autocomplete el[0], options

			# container =  $(el).parent().width()
			# $('.pac-container').css('width': container+' !important')

			google.maps.event.addListener autoComplete, 'places_changed', ->
				# places = searchBox.getPlaces()
				console.log 'places_changed'


		if document.readyState is "complete"
			initialize()
		else 
			google.maps.event.addDomListener window, 'load', initialize
]


.directive 'googleSearchTapDisable', ['$timeout', ($timeout)->

	link: ->
		$timeout ->
			container = document.getElementsByClassName 'pac-container'
			angular.element(container).attr 'data-tap-disabled', 'true'
			angular.element(container).on 'click', ->
				console.log 1
				# document.getElementById('type-selector').blur()

		, 500
]

