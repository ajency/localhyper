angular.module 'LocalHyper.suggestProduct', []


.controller 'suggestProductCtrl', ['$q', '$scope', ($q, $scope)->
	
	$scope.suggest = 
		productName: null
		category: null
		brand: null
		productDescription: null
		yourComments: null

		onSuggest :->
			defer = $q.defer()
			Product = Parse.Object.extend "suggestProduct"
			product = new Product()
			product.set "productName", $scope.suggest.productName
			product.set "category", $scope.suggest.category
			product.set "brand", $scope.suggest.brand
			product.set "productDescription", $scope.suggest.productDescription
			product.set "Comments", $scope.suggest.yourComments
			product.save()
			.then ->
				defer.resolve
			, (error)->
				defer.reject

			defer.promise

]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'suggest-product',
			url: '/suggest-product'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'suggestProductCtrl'
					templateUrl: 'views/suggest-product.html'
]