angular.module 'LocalHyper.brands'


.factory 'BrandsAPI', ['$q', '$http', ($q, $http)->

	BrandsAPI = {}

	BrandsAPI.getAll = (categoryID)->
		defer = $q.defer()
		params = "categoryId": categoryID

		$http.post 'functions/getCategoryBasedBrands', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	BrandsAPI
]