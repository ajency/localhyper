angular.module 'LocalHyper.products'


.controller 'MakeRequestCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
	, 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope', '$q', '$ionicModal'
	, ($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner
	, User, ProductsAPI, $ionicPopup, $rootScope, $q, $ionicModal)->

		$scope.view =
			latLng: null
			addressFetch: true
			sellerMarkers: []

			sellers:
				count: 0
				displayCount: false
				found: false

			comments: text: ''

			latitude : ''
			longitude: ''
			city : null

			userInfo: ''

			user :
				full : ''

			addressObj : ''

			display: 'loader'
			errorType: ''
			locationSet: true

			location:
				modal: null
				map: null
				marker: null
				latLng: null
				address: null
				addressFetch: true

				loadModal : ->
					defer = $q.defer()
					if _.isNull @modal
						$ionicModal.fromTemplateUrl 'views/products/location.html', 
							scope: $scope,
							animation: 'slide-in-up'
							hardwareBackButtonClose: false
						.then (modal)=> 
							defer.resolve @modal = modal
					else defer.resolve()
					defer.promise

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
						console.log '--107--'
						console.log @address
					, (error)->
						console.log 'Geocode error: '+error
					.finally =>
						@addressFetch = true

			beforeInit : ->
				@user.full = ''
				@latitude = ''
				@longitude = ''
				

			init : ->

				userInfo = User.getCurrent()
				@userInfo = userInfo.attributes
				if  _.isEmpty(@userInfo.address)
					console.log 'if user is not register'
					if _.isNull @latLng
						$timeout =>
							loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
							# @map.setCenter @toLatLng(loc)
							@getCurrent()
						, 200
					else
						@getCurrent()
				else
					@locationSet = true
					console.log 'if user is register'
					@display = 'noError'
					@latitude = @userInfo.addressGeoPoint._latitude
					@longitude = @userInfo.addressGeoPoint._longitude
					@city = @userInfo.address.city
					@user.full = @userInfo.address.full
					@addressObj = @userInfo.address
					@loadSeller()

		
			toLatLng : (loc)->
				latLng = new google.maps.LatLng loc.lat, loc.long
				latLng

			onMapCreated : (map)->
				@map = map
				
			getCurrent : ->
				GPS.isLocationEnabled()
				.then (enabled)=>
					if !enabled 
						@locationSet = false
						@display = 'noError'
					else
						CToast.show 'Getting current location'
						GPS.getCurrentLocation()
						.then (loc)=>
							console.log loc
							latLng = @toLatLng(loc)
							@latLng = latLng

							@addressFetch = false
							GoogleMaps.getAddress @latLng
							.then (address)=>
								console.log '--197---'
								console.log address
								@addressObj = address
								@address = address
								@address.full = GoogleMaps.fullAddress(address)
								console.log 'full'
								console.log @address.full
								@addressFetch = true

								@latitude = @latLng.H
								@longitude = @latLng.L
								@city = @address.city
								@user.full = @address.full
								@loadSeller()
							, (error)->
								@locationSet = false
								@display = 'noError'
								console.log 'Geocode error: '+error
						, (error)=>
							@locationSet = false
							@display = 'noError'
							CToast.show 'Error locating your position'

			isLocationReady : ->
				ready = if (@latitude != '' and @longitude != '') then true else false
				ready

			loadSeller : ->
				sellers = []
				console.log @userInfo
				console.log @latitude
				console.log @longitude
				CSpinner.show '', 'Please wait as we find sellers for your location'
				product = ProductsAPI.productDetails 'get'
				params = 
					"location": 
						latitude: @latitude
						longitude: @longitude
					"categoryId": product.category.id
					"brandId": product.brand.id 
					"city":  @city
					"area":  @city
				ProductsAPI.findSellers params
				.then (sellers)=>
					console.log sellers
					@sellers.count = sellers.length
					@display = 'noError'
				, (error)=>
					CToast.show 'Request failed, please try again'
					@display = 'error'
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
				console.log 'make request button'
				console.log @addressObj
				if !@isLocationReady()
					CToast.show 'Please select your location'
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
							latitude: @latitude
							longitude: @longitude
						"address": @addressObj
						"city": @city
						"area": @city

					console.log params
					console.log 'update'

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

			isGoogleMapsScriptLoaded : ->
				defer = $q.defer()
				if typeof google is 'undefined'
					CSpinner.show '', 'Please wait, loading resources...'
					GoogleMaps.loadScript()
					.then =>
						@location.loadModal()
					.then ->
						defer.resolve true
					, (error)->
						CToast.show 'Could not connect to server. Please try again'
						defer.resolve false
					.finally ->
						CSpinner.hide()
				else
					@location.loadModal().then ->
						defer.resolve true
				defer.promise

			onChangeLocation : ->
				@isGoogleMapsScriptLoaded().then (loaded)=>
					if loaded
						@location.modal.show()
						$timeout =>
							container = $('.map-content').height()
							children  = $('.address-inputs').height() + $('.tap-div').height()
							mapHeight = container - children - 20
							$('.aj-big-map').css 'height': mapHeight
							
							if @latitude != ''
								loc = lat: @latitude, long: @longitude
								latLng = @location.setMapCenter loc
								@location.map.setZoom 15
								@location.addMarker latLng
							else 
								@location.marker.setMap null if @location.marker
								@location.map.setZoom 5
								loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
								@location.setMapCenter loc
								@location.getCurrent()
						, 300

			onConfirmLocation : ->
				if !_.isNull(@location.latLng) and @location.addressFetch
					k = GoogleMaps.fullAddress(@location.address) 
					@address = k
					console.log @address
					@addressObj = @location.address
					@user.full = GoogleMaps.fullAddress(@location.address)
					@confirmedAddress = @location.address.full
					@latitude = @location.latLng.lat()
					@longitude = @location.latLng.lng()
					@city = @location.address.city
					@loadSeller()
					@location.modal.hide()
					@locationSet = true
				else
					CToast.show 'Please wait, getting location details...'

			onTapToRetry : ->
				@init()

		
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
