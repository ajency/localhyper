angular.module 'LocalHyper.products'


.controller 'SingleProductCtrl', ['$scope', '$stateParams', 'ProductsAPI'
	, ($scope, $stateParams, ProductsAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			productID: $stateParams.productID
			product: {}

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

