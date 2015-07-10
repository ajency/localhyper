angular.module 'LocalHyper.businessDetails', ['ngAutocomplete']


.controller 'BusinessDetailsCtrl', ['$scope', 'CToast', 'App', 'GPS', 'GoogleMaps', 'CDialog', 'User'
	, ($scope, CToast, App, GPS, GoogleMaps, CDialog, User)->

		$scope.view = 
			businessName: ''#'Ajency'
			userName: ''#'Deepak'
			phone: ''#'9765436351'
			map: null
			marker: null
			latLng: null
			geoCode: null
			address: null
			fullAddress: ''
			addrReqComplete: true
			deliveryRadius: 2
			terms: false
			addressConfirmed: false

			init : ->
				@getCurrentLocation()

			onMapCreated : (map)->
				@map = map
				google.maps.event.addListener @map, 'click', (event)=>
					@addMarker event.latLng

			getCurrentLocation : ->
				CToast.show 'Getting current location'
				GPS.getCurrentLocation()
				.then (loc)=>
					latLng = new google.maps.LatLng loc.lat, loc.long
					@map.setCenter latLng
					@map.setZoom 15
					@addMarker latLng
				, (err)->
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
				@addrReqComplete = false
				GoogleMaps.getAddress @latLng
				.then (address)=>
					@address = address
					@fullAddress = address.full
				, (error)->
					console.log 'Geocode error: '+error
				.finally =>
					@addrReqComplete = true

			onConfirmLocation : ->
				if !_.isNull(@latLng) and @addrReqComplete
					CDialog.confirm 'Confirm Location', 'Do you want to confirm this location?', ['Confirm', 'Cancel']
					.then (btnIndex)=>
						if btnIndex is 1
							@addressConfirmed = true
				else
					CToast.show 'Please wait...'

			onNext : ->
				if _.contains [@businessName, @userName, @phone], ''
					CToast.show 'Fill up all fields'
				else if _.isUndefined @phone
					CToast.show 'Please enter valid phone number'
				else if !@addressConfirmed
					CToast.show 'Please confirm your location'
				else
					@geoCode = 
						latitude: @latLng.lat()
						longitude: @latLng.lng()
					User.info 'set', $scope.view
					App.navigate 'categories'
		
		
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
						Maps : (GoogleMaps)->
							if typeof google is "undefined"
								GoogleMaps.loadScript()
]
