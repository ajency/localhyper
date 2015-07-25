angular.module 'LocalHyper.products'


.controller 'MakeRequestCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
	, ($scope, App, GPS, CToast, CDialog, $timeout)->

		$scope.view =
			latLng: null
			addressFetch: true

			toLatLng : (loc)->
				latLng = new google.maps.LatLng loc.lat, loc.long
				latLng

			onMapCreated : (map)->
				@map = map
				google.maps.event.addListener @map, 'click', (event)=>
					@addPlaceMarker event.latLng

			onPlacedChange : (latLng)->
				@latLng - latLng
				@map.setCenter latLng
				@map.setZoom 15
				@addPlaceMarker latLng

			init : ->
				if _.isNull @latLng
					$timeout =>
						loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
						@map.setCenter @toLatLng(loc)
						@getCurrent()
					, 200

			getCurrent : ->
				GPS.isLocationEnabled()
				.then (enabled)=>
					if !enabled then @showAlert()
					else
						CToast.show 'Getting current location'
						GPS.getCurrentLocation()
						.then (loc)=>
							latLng = @toLatLng(loc)
							@map.setCenter latLng
							@map.setZoom 15
							@addUserLocationMarker latLng
						, (error)->
							CToast.show 'Error locating your position'

			addUserLocationMarker : (latLng)->
				@latLng = latLng
				# @setAddress()
				@userMarker.setMap null if @userMarker
				@placeMarker.setMap null if @placeMarker
				@userMarker = new google.maps.Marker
					position: latLng
					map: @map
					icon: 'img/current-location.png'

				@userMarker.setMap @map

			addPlaceMarker : (latLng)->
				@latLng = latLng
				# @setAddress()
				@placeMarker.setMap null if @placeMarker
				@placeMarker = new google.maps.Marker
					position: latLng
					map: @map
					draggable: true

				@placeMarker.setMap @map
				google.maps.event.addListener @placeMarker, 'dragend', (event)=>
					@latLng = event.latLng
					# @setAddress()

			showAlert : ->
				positiveBtn = if App.isAndroid() then 'Open Settings' else 'Ok'
				CDialog.confirm 'Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']
				.then (btnIndex)->
					if btnIndex is 1 then GPS.switchToLocationSettings()



		$scope.$on '$ionicView.beforeEnter', ->
]



.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'make-request',
			url: '/make-request'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/make-request.html'
					controller: 'MakeRequestCtrl'
]
