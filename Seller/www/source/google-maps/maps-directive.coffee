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

.directive 'googleMapSearch', ['$timeout', ($timeout)->

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

			$(document).delegate ".pac-container .pac-item","click",() ->
				$timeout ->
						$('#locationSearch').blur()
				,500

		

		if document.readyState is "complete"
			initialize()
		else 
			google.maps.event.addDomListener window, 'load', initialize
]


.directive 'googleSearchTapDisable', ['$timeout', ($timeout)->

	link: ->
		$timeout ->
			# $ '.pac-container'
			# 	.click ->
			# 		console.log 'h'
			# 		# $('#locationSearch').blur()

			# $(document).delegate ".pac-container .pac-item .pac-selected","click",() ->
			# 	console.log 'hi'


		# , 500
]


# .directive 'googleMapSearch', [->

# 	restrict: 'A'

# 	link: (scope, el, attrs)->

# 		initialize = ->
# 			input = document.getElementById 'search'
# 			options = 
# 				componentRestrictions: country: 'in'

# 			autoComplete = new google.maps.places.Autocomplete el[0], options

# 			# container =  $(el).parent().width()
# 			# $('.pac-container').css('width': container+' !important')

# 			google.maps.event.addListener autoComplete, 'place_changed', ->
# 				# places = autoComplete.getPlaces()
# 				console.log 'place_changed'


# 		if document.readyState is "complete"
# 			initialize()
# 		else 
# 			google.maps.event.addDomListener window, 'load', initialize
# ]


# .directive 'googleSearchTapDisable', ['$timeout', ($timeout)->

# 	link: ->
# 		$timeout ->
# 			container = document.getElementsByClassName 'pac-container'
# 			angular.element(container).attr 'data-tap-disabled', 'true'
# 			angular.element(container).on 'click', ->
# 				console.log 1
# 				document.getElementById('type-selector').blur()

# 		, 500
# ]
