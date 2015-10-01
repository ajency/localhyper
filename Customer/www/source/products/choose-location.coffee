angular.module 'LocalHyper.products'


.controller 'ChooseLocationCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
	, 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope'
	, ($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner
	, User, ProductsAPI, $ionicPopup, $rootScope)->

		$scope.view =
			latLng: null
			addressFetch: true
			sellerMarkers: []

			sellers:
				count: 0
				displayCount: false
				found: false

			comments: text: ''
			
			beforeInit : ->
				@reset()
				@searchText = ''
				@comments.text = ''
				@address = null
				@latLng = null
				@map.setZoom 5

			setMapCenter : (loc)->
				latLng = new google.maps.LatLng loc.lat, loc.long
				@map.setCenter latLng
				latLng


			init : ->
				cordinates = GoogleMaps.setCordinates 'get'
				
				@latitude = cordinates.lat
				@longitude = cordinates.long

				if @latitude == ''
					$timeout =>
						loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
						@map.setCenter @toLatLng(loc)
						@getCurrent()
					, 200
				else
					loc = lat: @latitude, long: @longitude
					latLng = @setMapCenter loc
					@map.setZoom 15
					@addPlaceMarker latLng

			reset : (clearPlace = true)->
				App.resize()
				@userMarker.setMap null if @userMarker
				@placeMarker.setMap null if @placeMarker and clearPlace
				
				@sellers.found = false
				@sellers.displayCount = false

			toLatLng : (loc)->
				latLng = new google.maps.LatLng loc.lat, loc.long
				latLng

			onMapCreated : (map)->
				@map = map
				google.maps.event.addListener @map, 'click', (event)=>
					$scope.$apply =>
						@searchText = ''
						@addPlaceMarker event.latLng

			onPlaceChange : (latLng)->
				@latLng = latLng
				@map.setCenter latLng
				@map.setZoom 15
				@addPlaceMarker latLng

			getCurrent : ->
				GPS.isLocationEnabled()
				.then (enabled)=>
					if !enabled then @showAlert()
					else
						CToast.show 'Getting current location'
						GPS.getCurrentLocation()
						.then (loc)=>
							latLng = @toLatLng(loc)
							@searchText = ''
							@map.setCenter latLng
							@map.setZoom 15
							@addPlaceMarker latLng
						, (error)->
							CToast.show 'Error locating your position'

			addUserLocationMarker : (latLng)->
				@latLng = latLng
				@reset()
				@setAddress()
				@userMarker = new google.maps.Marker
					position: latLng
					map: @map
					icon: 'img/current-location.png'

				@userMarker.setMap @map

			addPlaceMarker : (latLng)->
				@latLng = latLng
				@reset()
				@setAddress()
				@placeMarker = new google.maps.Marker
					position: latLng
					map: @map
					draggable: true

				@placeMarker.setMap @map
				google.maps.event.addListener @placeMarker, 'dragend', (event)=>
					$scope.$apply =>
						@latLng = event.latLng
						@reset false
						@searchText = ''
						@setAddress()

			showAlert : ->
				positiveBtn = if App.isAndroid() then 'Open Settings' else 'Ok'
				CDialog.confirm 'Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']
				.then (btnIndex)->
					if btnIndex is 1 then GPS.switchToLocationSettings()

			setAddress : ->
				@addressFetch = false
				GoogleMaps.getAddress @latLng
				.then (address)=>
					@address = address
					@address.full = GoogleMaps.fullAddress(address)
					@addressFetch = true
				, (error)->
					console.log 'Geocode error: '+error
				# .finally =>
				# 	@addressFetch = true

			isLocationReady : ->
				ready = if (!_.isNull(@latLng) and @addressFetch) then true else false
				if !ready
					GPS.isLocationEnabled()
					.then (enabled)=>
						if enabled then CToast.show 'Please wait, getting location details...'
						else CToast.show 'Please search for location'
					
				ready


			confirmLocation :->
				if @isLocationReady()
					loc = lat: @latLng.lat(), long: @latLng.lng(), addressObj : @address
					GoogleMaps.setCordinates 'set' , loc 
					user = GoogleMaps.setCordinates 'get'
					console.log user
					App.navigate 'make-request'

		
		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.beforeInit()
			App.scrollTop()

		$scope.$on '$ionicView.afterEnter', ->
			$scope.view.init()
]



.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'choose-location',
			url: '/choose-location'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/choose-location.html'
					controller: 'ChooseLocationCtrl'
]
