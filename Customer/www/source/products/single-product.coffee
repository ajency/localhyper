angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal', 'GPS', 'GoogleMaps', 'CSpinner', 'CDialog', '$timeout'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GPS, GoogleMaps
	, CSpinner, CDialog, $timeout)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			productID: $stateParams.productID
			product: {}
			specificationModal: null
			makeRequestModal: null
			confirmedAddress: ''
			comments: 
				modal: null
				text: ''
			
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

			

			init: ->
				@loadSpecificationsModal()
				@loadMakeRequestModal()
				@loadLocationModal()
				@loadCommentsModal()
				@getSingleProductDetails()

			loadSpecificationsModal : ->
				$ionicModal.fromTemplateUrl 'views/products/specification.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@specificationModal = modal

			loadMakeRequestModal : ->
				$ionicModal.fromTemplateUrl 'views/products/make-request.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@makeRequestModal = modal

			loadLocationModal : ->
				$ionicModal.fromTemplateUrl 'views/products/location.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@location.modal = modal

			loadCommentsModal : ->
				$ionicModal.fromTemplateUrl 'views/products/comments.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@comments.modal = modal

			getSingleProductDetails : ->
				ProductsAPI.getSingleProduct @productID
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error

			onSuccess : (data)->
				@display = 'noError'
				@product = data
				
			onError: (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getSingleProductDetails()

			onEditLocation : ->
				@location.modal.show()
				mapHeight = $('.map-content').height()
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
							@confirmedAddress = @location.address.full
							@location.modal.hide()
				else
					CToast.show 'Please wait, getting location details...'

			checkUserLogin : ->
				if !User.isLoggedIn()
					App.navigate 'verify-begin'
				else
					user = User.getCurrent()
					address = user.get 'address'
					@confirmedAddress = if _.isUndefined(address) then '' else address.full
					@makeRequestModal.show()

			beforeMakeRequest : ->
				if @confirmedAddress is ''
					CToast.show 'Please select your location'
				else
					@makeRequest()

			makeRequest : ->
				CSpinner.show '', 'Please wait...'
				params = 
					"customerId": User.getId()
					"productId": @productID
					"location": 
						latitude: @location.latLng.lat()
						longitude: @location.latLng.lng()
					"categoryId": @product.category.objectId
					"brandId": @product.brand.objectId
					"address": @location.address
					"city": @location.address.city
					"area": @location.address.city
					"comments": ""
					"status": "open"
					"deliveryStatus": ""

				User.update
					"address": params.address
					"addressGeoPoint": new Parse.GeoPoint params.location
					"area": params.area
					"city": params.city
				.then ->
					ProductsAPI.makeRequest params
				.then =>
					@makeRequestModal.hide()
					CToast.show 'Your request has been made'
				, (error)->
					CToast.show 'Request failed, please try again'
				.finally ->
					CSpinner.hide()

		$scope.$on '$destroy', ->
			$scope.view.specificationModal.remove()
			$scope.view.makeRequestModal.remove()
			$scope.view.location.modal.remove()
			$scope.view.comments.modal.remove()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'single-product',
			url: '/single-product:productID'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					templateUrl: 'views/products/single-product.html'
					controller: 'SingleProductCtrl'
					resolve:
						Maps : (GoogleMaps)->
							GoogleMaps.loadScript()
]

