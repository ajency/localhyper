angular.module 'LocalHyper.googleMaps'


.directive 'googleMap', ['$timeout', ($timeout)->

	restrict: 'E'
	replace: true
	template: '<div data-tap-disabled="{{mapTapDisabled}}">'
	scope:
		mapTapDisabled: '='
		onCreate: '&'

	link:(scope, el, attr)->

		hideAnchorTags = ->
			$timeout ->
				$(el).find('a').parent().hide()

		initialize = ->
			mapOptions = 
				center: new google.maps.LatLng 20.593684, 78.962880 
				zoom: 5
				mapTypeId: google.maps.MapTypeId.ROADMAP
				zoomControl: false
				mapTypeControl: false
				streetViewControl: false
			
			map = new google.maps.Map el[0], mapOptions
			google.maps.event.addListenerOnce map, 'load', ->
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

