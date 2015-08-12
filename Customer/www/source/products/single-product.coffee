angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal', 'GoogleMaps', 'CSpinner', '$rootScope', 'RequestAPI'
	, '$ionicScrollDelegate', '$ionicPlatform'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal, GoogleMaps
	, CSpinner, $rootScope, RequestAPI, $ionicScrollDelegate, $ionicPlatform)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			footer: false
			productID: $stateParams.productID
			product: {}

			request:
				page: 0
				all: []
				active: false
				limitTo: 1
				canLoadMore: false
				display: 'none'

				onScrollComplete : ->
					$scope.$broadcast 'scroll.infiniteScrollComplete'

				checkIfActive: ->
					@active = false
					if User.isLoggedIn()
						@active = !_.isEmpty($scope.view.product.activeRequest)

				reset : ->
					@page = 0
					@all = []
					@active = false
					@limitTo = 1
					@canLoadMore = false
					@display = 'none'

				reFetch : ->
					@page = 0
					@all = []
					@limitTo = 1
					@canLoadMore = false
					@display = 'loader'
					@get()
					App.resize()

				showAllRequests : ->
					@limitTo = 1000
					@canLoadMore = true
					App.scrollBottom()

				get : ->
					params = 
						productId: $scope.view.productID
						page: @page
						displayLimit: 2
						requestType: 'all'
						selectedFilters: []

					RequestAPI.get params
					.then (data)=>
						@success data, params.displayLimit
					, (error)=>
						@onError error
					.finally =>
						@page = @page + 1
						App.resize()

				success : (data, limit)->
					@display = 'noError'
					if _.size(data) > 0
						if _.size(data) < limit then @canLoadMore = false
						else @onScrollComplete()
						@all = @all.concat data
					else @canLoadMore = false

				onError : (error)->
					console.log error
					@display = 'error'
					@canLoadMore = false

				onTryAgain : ->
					@display = 'noError'
					@page = 0
					@all = []
					@canLoadMore = true

				onCardClick : (request)->
					RequestAPI.requestDetails 'set', request
					App.navigate 'request-details'


			specifications :
				modal: null

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/products/specifications.html', 
						scope: $scope,
						animation: 'slide-in-up'
						hardwareBackButtonClose: false
					.then (modal)=>
						@modal = modal

				openModal : ->
					$ionicScrollDelegate
						.$getByHandle 'specification-modal-handle'
						.scrollTop true
					@modal.show()

				set : ->
					groups = _.groupBy window.specifications, (spec)-> spec.group
					
					general = groups['general']
					generalSpecs = []
					_.each general, (specs)->
						generalSpecs.push App.humanize specs.value
					@excerpt = generalSpecs.join ', '

					warranty = groups['warranty']
					delete groups['general']
					delete groups['warranty']
					groups = _.toArray groups
					groups.unshift general
					groups.push warranty
					@groups = groups

			
			
			init : ->
				@specifications.loadModal()

			reset : ->
				@display = 'loader'
				@footer = false
				@request.reset()
				@getSingleProductDetails()

			getSingleProductDetails : ->
				ProductsAPI.getSingleProduct @productID
				.then (productData)=>
					console.log productData
					@product = productData
					ProductsAPI.getNewOffers @productID
				.then (details)=>
					_.each details, (val, key)=>
						@product[key] = val
					@onSuccess()
				, (error)=>
					@onError error
				.finally ->
					App.resize()

			onSuccess : ->
				@footer = true
				@display = 'noError'
				@specifications.set()
				@request.checkIfActive()
				if User.isLoggedIn()
					@request.display = 'loader'
					@request.get()
				
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
					CSpinner.show '', 'Please wait, loading resources'
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


		
		onDeviceBack = ->
			specificationModal = $scope.view.specifications.modal
			if !_.isNull(specificationModal) && specificationModal.isShown()
				specificationModal.hide()
			else
				App.goBack -1

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack

		$rootScope.$on 'make:request:success', ->
			$scope.view.request.active = true
			$scope.view.request.reFetch()

		$rootScope.$on 'request:cancelled', ->
			$scope.view.request.active = false

		$rootScope.$on 'offer:accepted', ->
			$scope.view.request.active = false

		$rootScope.$on 'on:session:expiry', ->
			$scope.view.reset()

		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload

			if payload.type is 'new_offer'
				$scope.view.request.reFetch()
		
		$scope.$on '$ionicView.beforeEnter', ->
			if _.contains ['products', 'verify-success'], App.previousState
				$ionicScrollDelegate
					.$getByHandle 'single-product-handle'
					.scrollTop true
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

