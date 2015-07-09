angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI', 'User'
	, 'CToast', 'App', '$ionicModal'
	, ($scope, $stateParams, ProductsAPI, User, CToast, App, $ionicModal)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			productID: $stateParams.productID
			product: {}
			specificationModal: null

			init: ->
				@loadSpecificationsModal()

			loadSpecificationsModal : ->
				$ionicModal.fromTemplateUrl 'views/products/specification.html', 
					scope: $scope,
					animation: 'slide-in-up'
				.then (modal)=>
					@specificationModal = modal

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

			onMakeRequest : ->
				if User.isLoggedIn()
					CToast.show 'User session active'
				else
					App.navigate 'verify-begin'

		
		$scope.$on '$ionicView.loaded', ->
			$scope.view.getSingleProductDetails()
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

