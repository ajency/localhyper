angular.module 'LocalHyper.products'


.controller 'MakeRequestCtrl', ['$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout'
	, 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope', '$q'
	, ($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner
	, User, ProductsAPI, $ionicPopup, $rootScope, $q)->

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

			beforeInit : ->
				@user.full = ''
				@latitude = ''
				@longitude = ''
				
			init : ->
				if App.previousState != 'choose-location'
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
				else
						console.log 'choose-location'
						cordinates = GoogleMaps.setCordinates 'get'
						@latitude = cordinates.lat
						@longitude = cordinates.long
						loc = lat: @latitude, long: @longitude
						@locationSet = true
						@display = 'noError'
						@latitude = cordinates.lat
						@longitude = cordinates.long
						@city = cordinates.addressObj.city
						@user.full = cordinates.addressObj.full
						@addressObj = cordinates.addressObj
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
								@addressObj = address
								@address = address
								@address.full = GoogleMaps.fullAddress(address)
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

			onChangeLocation : ->
				loc = lat: @latitude, long: @longitude , addressObj : @addressObj
				# App.navigate 'choose-location'
				GoogleMaps.setCordinates 'set' , loc 
				App.navigate 'choose-location'

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
