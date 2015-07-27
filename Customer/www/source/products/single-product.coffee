angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps
	, CSpinner, $rootScope)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			footer: false
			productID: $stateParams.productID
			product: {}

			request:
				active: false
				check: ->
					@active = false
					if User.isLoggedIn()
						@active = !_.isEmpty($scope.view.product.activeRequest)

			reset : ->
				@display = 'loader'
				@footer = false
				@getSingleProductDetails()

			getSingleProductDetails : ->
				ProductsAPI.getSingleProduct @productID
				.then (productData)=>
					@product = productData
					ProductsAPI.getNewOffers @productID
				.then (details)=>
					_.each details, (val, key)=>
						@product[key] = val
					console.log @product
					@onSuccess()
				, (error)=>
					@onError error

			onSuccess : ->
				@footer = true
				App.resize()
				@request.check()
				@display = 'noError'
				
			onError: (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getSingleProductDetails()

			getPrimaryAttrs : ->
				if !_.isUndefined @product.primaryAttributes
					attrs = @product.primaryAttributes[0]
					value = s.humanize attrs.value
					unit = ''
					if _.has attrs.attribute, 'unit'
						unit = s.humanize attrs.attribute.unit
					"#{value} #{unit}"
				else ''

			checkUserLogin : ->
				if !User.isLoggedIn()
					App.navigate 'verify-begin'
				else if _.isUndefined window.google
					CSpinner.show '', 'Please wait...'
					GoogleMaps.loadScript()
					.then => 
						@getBestPrices()
					,(error)-> 
						CToast.show 'Error loading content, please check your network settings'
					.finally -> 
						CSpinner.hide()
				else
					@getBestPrices()

			getBestPrices : ->
				ProductsAPI.productDetails 'set', @product
				App.navigate 'make-request'


		$rootScope.$on 'make:request:success', ->
			$scope.view.request.active = true
		
		$scope.$on '$ionicView.beforeEnter', ->
			if _.contains ['products'], App.previousState
				$scope.view.reset()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'single-product',
			url: '/single-product:productID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/single-product.html'
					controller: 'SingleProductCtrl'
]

