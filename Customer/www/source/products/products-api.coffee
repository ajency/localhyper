angular.module 'LocalHyper.products'


.factory 'ProductsAPI', ['$q', '$http', 'User', 'App', ($q, $http, User, App)->

	ProductsAPI = {}
	productDetails = {}

	ProductsAPI.getAll = (opts)->
		defer = $q.defer()

		selectedFilters = opts.selectedFilters
		brands = selectedFilters.brands
		price = selectedFilters.price
		otherFilters = selectedFilters.otherFilters
		if _.isEmpty(brands) and _.isEmpty(price) and _.isEmpty(otherFilters)
			selectedFilters = "all"

		params = 
			"categoryId": opts.categoryID
			"selectedFilters": selectedFilters
			"sortBy": opts.sortBy
			"ascending": opts.ascending
			"page": opts.page
			"displayLimit": opts.displayLimit
			"searchKeywords": opts.searchKeywords

		$http.post 'functions/getProductsNew', params
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
			params = "productId": productId 
			App.erro(error,params,'getProduct')
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

	ProductsAPI.productDetails = (action, data={})->
		switch action
			when 'set'
				productDetails = data
			when 'get'
				productDetails

	ProductsAPI.findSellers = (params)->
		defer = $q.defer()
		$http.post 'functions/getLocationBasedSellers', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			App.erro(error,params,'getLocationBasedSellers')
			defer.reject error

		defer.promise

	ProductsAPI
]
