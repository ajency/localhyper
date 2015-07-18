angular.module 'LocalHyper.suggestProduct', []


.controller 'suggestProductCtrl', ['$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI', ($q, $scope, $http, $location, CToast, CategoriesAPI)->
	$scope.suggest = {}

	CategoriesAPI.getAll()
	.then (categories)->
		console.log(categories)
		$scope.suggest.items = categories
	
	$scope.suggest = 
		productName: null
		category: null
		brand: null
		productDescription: null
		yourComments: null

		onSuggest :->
			defer = $q.defer()
			param = {"productName" : $scope.suggest.productName,"category" : $scope.suggest.category.name,"brand": $scope.suggest.brand,"description" : $scope.suggest.productDescription,"comments" : $scope.suggest.yourComments}
			$http.post 'functions/sendMail', param
			.then (data)->
				defer.resolve
				$location.path '/categories'	
			, (error)->
				CToast.show('Request failed, please try again')
				defer.reject error

		 defer.promise	

	


	

	

]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'suggest-product',
			url: '/suggest-product'
			parent: 'main',
			cache: false,
			views: 
				"appContent":
					controller: 'suggestProductCtrl'
					templateUrl: 'views/suggest-product.html'
]