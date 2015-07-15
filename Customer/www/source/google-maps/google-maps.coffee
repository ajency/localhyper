angular.module 'LocalHyper.googleMaps', []


.factory 'GoogleMaps', ['$q', ($q)->

	GoogleMaps = {}

	GoogleMaps.loadScript = ->
		defer = $q.defer()
		script = document.createElement 'script'
		script.type = 'text/javascript'
		script.src  = "https://maps.googleapis.com/maps/api/js?libraries=places"+
					  "&key=#{GOOGLE_MAPS_API_KEY}&callback=onGMapScriptLoad"
		
		document.body.appendChild script
		window.onGMapScriptLoad = -> defer.resolve()
		script.onerror = -> defer.reject()

		defer.promise

	GoogleMaps.getAddress = (latLng)->
		defer = $q.defer()
		geocoder = new google.maps.Geocoder()
		geocoder.geocode 'latLng': latLng, (results, status)=>
			if status is google.maps.GeocoderStatus.OK
				address = @formatAddress results
				defer.resolve address
			else
				defer.reject status

		defer.promise

	GoogleMaps.formatAddress = (results)->
		address = {}
		data = results[0]
		address.full = data.formatted_address

		_.each data.address_components, (addr)->
			switch addr.types[0]
				when 'route'
					address.address_line1 = addr.long_name
				when 'sublocality_level_2'
					address.address_line2 = addr.long_name
				when 'sublocality_level_1'
					address.address_line3 = addr.long_name
				when 'locality'
					address.city = addr.long_name
				when 'administrative_area_level_2'
					address.district = addr.long_name
				when 'administrative_area_level_1'
					address.state = addr.long_name
				when 'country'
					address.country = addr.long_name
				when 'postal_code'
					address.postal_code = addr.long_name
					
		address

	GoogleMaps
]