angular.module 'LocalHyper.products'


.factory 'ProductsAPI', ['$q', '$http', ($q, $http)->

	ProductsAPI = {}

	ProductsAPI.getAll = (opts)->
		defer = $q.defer()

		params = 
			"categoryId": "#{opts.categoryID}"
			"selectedFilters": "all"
			"sortBy": opts.sortBy
			"ascending": opts.ascending
			"page": opts.page
			"displayLimit": 10

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

	ProductsAPI.makeRequest = (productId)->
		defer = $q.defer()

		$http.post 'functions/makeRequest', "productId": productId
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	ProductsAPI
]
