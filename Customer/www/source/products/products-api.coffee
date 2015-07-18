angular.module 'LocalHyper.products'


.factory 'ProductsAPI', ['$q', '$http', 'User', ($q, $http, User)->

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

	ProductsAPI.makeRequest = (params)->
		defer = $q.defer()

		$http.post 'functions/makeRequest', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	ProductsAPI.getNewOffers = (productId)->
		defer = $q.defer()

		if User.isLoggedIn()
			params = 
				"productId": productId
				"customerId": User.getId()

			$http.post 'functions/getNewOffers', params
			.then (data)->
				defer.resolve data.data.result
			, (error)->
				defer.reject error
		else
			defer.resolve {}

		defer.promise

	ProductsAPI
]
