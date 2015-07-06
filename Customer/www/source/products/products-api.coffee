angular.module 'LocalHyper.products'


.factory 'ProductsAPI', ['$q', '$http', ($q, $http)->

	ProductsAPI = {}

	ProductsAPI.getAll = (opts)->
		defer = $q.defer()

		params = 
			"categoryId": "#{opts.categoryID}"
			"selectedFilters": "all"
			"sortBy": "popularity"
			"ascending": false
			"page": opts.page
			"displayLimit": 6

		$http.post 'functions/getProducts', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	ProductsAPI.getSingleProduct = (productId)->
		defer = $q.defer()

		$http.post 'functions/getProduct', "productId": productId
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	ProductsAPI
]
