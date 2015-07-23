angular.module 'LocalHyper.suggestProduct', []


.controller 'suggestProductCtrl', ['$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI'
	, ($q, $scope, $http, $location, CToast, CategoriesAPI)->

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
				param = 
					"productName" : @productName
					"category" :@category.name
					"brand": @brand
					"description" : @productDescription
					"comments" : @yourComments

				$http.post 'functions/sendMail', param
				.then (data)->
					$location.path '/categories'	
				, (error)->
					CToast.show('Request failed, please try again')
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
