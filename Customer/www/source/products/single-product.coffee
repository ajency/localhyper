angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope', 'RequestAPI'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps
	, CSpinner, $rootScope, RequestAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			footer: false
			productID: $stateParams.productID
			product: {}

			request:
				page: 0
				canLoadMore: false
				all: []
				open: null
				active: false
				showAll: false
				error: false

				onScrollComplete : ->
					$scope.$broadcast 'scroll.infiniteScrollComplete'

				checkIfActive: ->
					@active = false
					if User.isLoggedIn()
						@active = !_.isEmpty($scope.view.product.activeRequest)

				reset : ->
					@page = 0
					@canLoadMore = false
					@all = []
					@open = null
					@active = false
					@showAll = false

				showAllRequests : ->
					@showAll = true
					@page = 0
					@all = []
					@canLoadMore = true

				get : ->
					params = 
						productId: $scope.view.productID
						page: @page
						displayLimit: 3
						openStatus: false

					RequestAPI.get params
					.then (data)=>
						if _.size(data) > 0
							if _.size(data) < params.displayLimit then @canLoadMore = false
							else @onScrollComplete()
							if @showAll then @open = null
							else @open = _.first data
							@all = @all.concat data
							console.log data
						else @canLoadMore = false
					, (error)=>
						console.log error
					.finally =>
						@page = @page + 1
						App.resize()


			reset : ->
				@display = 'loader'
				@footer = false
				@request.reset()
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
				.finally ->
					App.resize()

			onSuccess : ->
				@footer = true
				@display = 'noError'
				@request.checkIfActive()
				@request.get() if User.isLoggedIn()
				
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

		$rootScope.$on 'on:session:expiry', ->
			$scope.view.reset()
		
		$scope.$on '$ionicView.beforeEnter', ->
			if _.contains ['products', 'verify-success'], App.previousState
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

