angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal', 'GPS', 'GoogleMaps', 'CSpinner'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GPS, GoogleMaps, CSpinner)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			productID: $stateParams.productID
			product: {}
			specificationModal: null
			makeRequestModal: null
			addrReqComplete: true
			latLng: null
			address: null
			fullAddress: ''

			init: ->
				@loadSpecificationsModal()
				@loadMakeRequestModal()

			loadSpecificationsModal : ->
				$ionicModal.fromTemplateUrl 'views/products/specification.html', 
					scope: $scope,
					animation: 'slide-in-up'
				.then (modal)=>
					@specificationModal = modal

			loadMakeRequestModal : ->
				$ionicModal.fromTemplateUrl 'views/products/make-request.html', 
					scope: $scope,
					animation: 'slide-in-up'
				.then (modal)=>
					@makeRequestModal = modal

			getSingleProductDetails : ->
				ProductsAPI.getSingleProduct @productID
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error

			onSuccess : (data)->
				@display = 'noError'
				@product = data
				console.log data
				
			onError: (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getSingleProductDetails()

			checkUserLogin : ->
				if User.isLoggedIn()
					@makeRequestModal.show()
					@getCurrentLocation()
				else
					App.navigate 'verify-begin'

			getCurrentLocation : ->
				CToast.show 'Getting current location'
				GPS.getCurrentLocation()
				.then (loc)=>
					@latLng = new google.maps.LatLng loc.lat, loc.long
					@setAddress()
				, (err)->
					CToast.show 'Error locating your position'

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

			beforeMakeRequest : ->
				if _.isNull(@latLng) or !@addrReqComplete
					CToast.show 'Please wait...'
				else
					@makeRequest()

			makeRequest : ->
				CSpinner.show '', 'Please wait...'
				params = 
					"customerId": User.getId()
					"productId": @productID
					"location": latitude: @latLng.lat(), longitude: @latLng.lng()
					"categoryId": @product.category.objectId
					"brandId": @product.brand.objectId
					"address": @address
					"city": @address.city
					"area": @address.city
					"comments": ""
					"status": "open"
					"deliveryStatus": ""

				ProductsAPI.makeRequest params
				.then (res)=>
					@makeRequestModal.hide()
					CToast.show 'Your request has been made'
				, (error)->
					CToast.show 'Request failed, please try again'
				.finally ->
					CSpinner.hide()
		
		$scope.$on '$ionicView.loaded', ->
			$scope.view.getSingleProductDetails()

		$scope.$on '$destroy', ->
			$scope.view.specificationModal.remove()
			$scope.view.makeRequestModal.remove()
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
							if typeof google is "undefined"
								GoogleMaps.loadScript()
]

