angular.module 'LocalHyper.products'


.controller 'MakeRequestCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
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


			init : ->
				if _.isNull @latLng
					$timeout =>
						loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
						@map.setCenter @toLatLng(loc)
						@getCurrent()
					, 200
				else
					@getCurrent()

			reset : (clearPlace = true)->
				App.resize()
				@userMarker.setMap null if @userMarker
				@placeMarker.setMap null if @placeMarker and clearPlace
				@clearSellerMarkers()
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
							@addUserLocationMarker latLng
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

			addSellerMarkers : (sellers)->
				@sellers.count = _.size sellers
				@sellers.displayCount = true
				@sellers.found = true #if @sellers.count > 0 then true else false

				_.each sellers, (seller)=>
					geoPoint = seller.sellerGeoPoint
					loc = lat: geoPoint.latitude, long: geoPoint.longitude
					@sellerMarkers.push new google.maps.Marker
						position: @toLatLng loc
						map: @map
						icon: 'img/shop.png'

			clearSellerMarkers : ->
				_.each @sellerMarkers, (marker)-> marker.setMap null

			findSellers : ->
				if @isLocationReady()
					@sellers.displayCount = false
					@clearSellerMarkers()
					CSpinner.show '', 'Please wait as we find sellers for your location'
					product = ProductsAPI.productDetails 'get'
					params = 
						"location": 
							latitude: @latLng.lat()
							longitude: @latLng.lng()
						"categoryId": product.category.id
						"brandId": product.brand.id 
						"city": @address.city
						"area": @address.city
					ProductsAPI.findSellers params
					.then (sellers)=>
						@addSellerMarkers sellers
						App.scrollTop()
					, (error)->
						CToast.show 'Request failed, please try again'
					.finally ->
						App.resize()
						CSpinner.hide()

			addComments : ->
				@comments.temp = @comments.text
				$ionicPopup.show
					template:   '<div class="list">
									<label class="item item-input">
										<textarea 
											placeholder="Comments"
											ng-model="view.comments.temp">
										</textarea>
									</label>
								</div>'
					title: 'Add comments'
					scope: $scope
					buttons: [
						{ text: 'Cancel' }
						{ 
							text: '<b>Save</b>'
							type: 'button-positive'
							onTap: (e)=> @comments.text = @comments.temp
						}]

			makeRequest : ->
				if @isLocationReady()
					if !App.isOnline()
						CToast.show UIMsg.noInternet
					else
						product = ProductsAPI.productDetails 'get'
						CSpinner.show '', 'Please wait...'
						params =  
							"customerId": User.getId()
							"productId": product.id
							"categoryId": product.category.id
							"brandId": product.brand.id
							"comments": @comments.text
							"status": "open"
							"deliveryStatus": ""
							"location": 
								latitude: @latLng.lat()
								longitude: @latLng.lng()
							"address": @address
							"city": @address.city
							"area": @address.city

						User.update 
							"address": params.address
							"addressGeoPoint": new Parse.GeoPoint params.location
							"area": params.area
							"city": params.city
						.then ->
							ProductsAPI.makeRequest params
						.then =>
							CToast.show 'Your request has been made'
							$rootScope.$broadcast 'make:request:success'
							$timeout =>
								App.goBack -1
							, 500
						, (error)->
							CToast.show 'Request failed, please try again'
						.finally ->
							CSpinner.hide()

		
		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.beforeInit()
			App.scrollTop()

		$scope.$on '$ionicView.afterEnter', ->
			$scope.view.init()
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
