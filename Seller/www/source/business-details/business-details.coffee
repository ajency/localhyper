angular.module 'LocalHyper.businessDetails', ['ngAutocomplete']


.controller 'BusinessDetailsCtrl', ['$scope', 'CToast', 'App', 'GPS', 'GoogleMaps'
	, 'CDialog', 'User', '$ionicModal', '$timeout', 'Storage'
	, ($scope, CToast, App, GPS, GoogleMaps, CDialog, User, $ionicModal, $timeout, Storage)->

	
		$scope.view = 
			name:''
			phone:''
			businessName:''
			confirmedAddress: ''
			terms: false

			delivery:
				radius: 10
				plus : ->
					@radius++ if @radius < 99
				minus : ->
					@radius-- if @radius > 1

			location:
				modal: null
				map: null
				marker: null
				latLng: null
				address: null
				addressFetch: true

				showAlert : ->
					positiveBtn = if App.isAndroid() then 'Open Settings' else 'Ok'
					CDialog.confirm 'Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']
					.then (btnIndex)->
						if btnIndex is 1
							GPS.switchToLocationSettings()

				onMapCreated : (map)->
					@map = map
					google.maps.event.addListener @map, 'click', (event)=>
						@addMarker event.latLng

				setMapCenter : (loc)->
					latLng = new google.maps.LatLng loc.lat, loc.long
					@map.setCenter latLng
					latLng

				getCurrent : ->
					GPS.isLocationEnabled()
					.then (enabled)=>
						if !enabled
							@showAlert()
						else
							CToast.show 'Getting current location'
							GPS.getCurrentLocation()
							.then (loc)=>
								latLng = @setMapCenter loc
								@map.setZoom 15
								@addMarker latLng
							, (error)->
								CToast.show 'Error locating your position'

				addMarker : (latLng)->
					@latLng = latLng
					@setAddress()
					@marker.setMap null if @marker
					@marker = new google.maps.Marker
						position: latLng
						map: @map
						draggable: true

					@marker.setMap @map
					google.maps.event.addListener @marker, 'dragend', (event)=>
						@latLng = event.latLng
						@setAddress()

				setAddress : ->
					@addressFetch = false
					GoogleMaps.getAddress @latLng
					.then (address)=>
						@address = address
					, (error)->
						console.log 'Geocode error: '+error
					.finally =>
						@addressFetch = true

			init : ->
				@loadLocationModal()
				@initializebusinessValue()
				
			initializebusinessValue : ->
				Storage.bussinessDetails 'get','null'
				.then (value) =>
					if !_.isNull value 
						@name = value.name
						@phone = value.phone
						@businessName = value.businessName
						@confirmedAddress = value.confirmedAddress
						@delivery.radius =  value.deliveryRadius
						@latitude =  value.latitude
						@longitude =  value.longitude
						@location.latLng = new google.maps.LatLng value.latitude, value.longitude
						@location.address = value.address
						
			loadLocationModal : ->
				$ionicModal.fromTemplateUrl 'views/business-details/location.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@location.modal = modal

			onChangeLocation : ->
				
				@location.modal.show()
				mapHeight = $('.map-content').height() - $('.address-inputs').height() - 10
				$('.aj-big-map').css 'height': mapHeight
				if _.isNull @location.latLng
					$timeout =>
						loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
						@location.setMapCenter loc
						@location.getCurrent()
					, 200
				else 
					$timeout =>
						loc = lat: @latitude, long: @longitude
						latLng = @location.setMapCenter loc
						@location.map.setZoom 15
						@location.addMarker latLng
					, 200



			onConfirmLocation : ->
				if !_.isNull(@location.latLng) and @location.addressFetch
					CDialog.confirm 'Confirm Location', 'Do you want to confirm this location?', ['Confirm', 'Cancel']
					.then (btnIndex)=>
						if btnIndex is 1
							@location.address.full = GoogleMaps.fullAddress(@location.address)
							@confirmedAddress = @location.address.full
							@location.modal.hide()
				else
					CToast.show 'Please wait, getting location details...'

			onNext : ->
				if _.contains [@businessName, @name, @phone], ''
					CToast.show 'Fill up all fields'
				else if _.isUndefined @phone
					CToast.show 'Please enter valid phone number'
				else if @confirmedAddress is ''
					CToast.show 'Please select your location'
				else
					@latitude = @location.latLng.lat()
					@longitude = @location.latLng.lng()
					User.info 'set', $scope.view
					Storage.bussinessDetails 'set',
						name: @name
						phone: @phone
						businessName: @businessName
						address: @location.address
						confirmedAddress: @confirmedAddress
						latitude: @latitude
						longitude: @longitude
						deliveryRadius: @delivery.radius
					.then ->
						App.navigate 'category-chains'
		
		
		$scope.$on '$ionicView.enter', ->
			App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'business-details',
			url: '/business-details'
			parent: 'main'
			views: 
				"appContent":
					controller: 'BusinessDetailsCtrl'
					templateUrl: 'views/business-details/business-details.html'
					resolve:
						Maps : ($q, CSpinner, GoogleMaps)->
							defer = $q.defer()
							CSpinner.show '', 'Please wait...'
							GoogleMaps.loadScript()
							.then ->
								defer.resolve()
							.finally ->
								CSpinner.hide()
							defer.promise
]

