angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$scope', 'User', 'App', 'CDialog', 'GPS', 'CToast'
	, 'GoogleMaps', '$ionicModal'
	, ($scope, User, App, CDialog, GPS, CToast, GoogleMaps, $ionicModal)->

		user = User.getCurrent()

		$scope.view = 
			name: user.get 'displayName'
			phone: "+91-#{user.get('username')}"

			profileAddress: ''

			permanentAddress:
				obj: user.get 'permanentAddress'
				available: -> !_.isUndefined @obj

			tempAddress:
				obj: user.get 'address'
				available: -> !_.isUndefined @obj

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
				@checkForAddress()

			loadLocationModal : ->
				$ionicModal.fromTemplateUrl 'views/location.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@location.modal = modal

			checkForAddress : ->
				if @permanentAddress.available()
					@profileAddress = @permanentAddress.obj.full
				else if @tempAddress.available()
					@profileAddress = @tempAddress.obj.full

			onEditLocation : ->
				@location.modal.show()
				mapHeight = $('.map-content').height() - $('.address-inputs').height() - 10
				$('.aj-big-map').css 'height': mapHeight
				if _.isNull @location.latLng
					$timeout =>
						loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
						@location.setMapCenter loc
						@location.getCurrent()
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



		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true

		$scope.$on '$destroy', ->
			$scope.view.location.modal.remove()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'profile',
			url: '/Seller-profile'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'ProfileCtrl'
					templateUrl: 'views/profile/profile.html'
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
