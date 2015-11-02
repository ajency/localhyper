angular.module 'LocalHyper.businessDetails'


.controller 'ChooseLocationCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
	, 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', '$ionicPopup', '$rootScope'
	, ($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner
	, User, $ionicPopup, $rootScope)->

		$scope.view =
			latLng: null
			addressFetch: true

			disableTap :->
				container = document.getElementsByClassName('pac-container')
				angular.element(container).attr('data-tap-disabled', 'true')
				return

			beforeInit : ->
				@reset()
				@searchText = ''
				@address = null
				@latLng = null
				@map.setZoom 5

			setMapCenter : (loc)->
				latLng = new google.maps.LatLng loc.lat, loc.long
				@map.setCenter latLng
				latLng

			init : ->
				cordinates = GoogleMaps.setCordinates 'get'
				if !_.isEmpty cordinates
					loc = lat: cordinates.latitude, long: cordinates.longitude
					latLng = @setMapCenter loc
					@map.setZoom 15
					@addPlaceMarker latLng
				else 
					loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
					@map.setCenter @toLatLng(loc)
					@getCurrent()

			reset : (clearPlace = true)->
				App.resize()
				@placeMarker.setMap null if @placeMarker and clearPlace

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
				console.log 'place channge'
				$('#locationSearch').blur()
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
					value = latitude: @latLng.lat(), longitude: @latLng.lng(), addressObj : @address
					GoogleMaps.setCordinates 'set' , value 
					App.navigate 'business-details'
				else
					CToast.show 'Please wait, getting location details...'
		
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
			cache : false
			views: 
				"appContent":
					templateUrl: 'views/business-details/choose-location.html'
					controller: 'ChooseLocationCtrl'
]
