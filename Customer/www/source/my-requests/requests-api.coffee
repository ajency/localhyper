angular.module 'LocalHyper.myRequests'


.factory 'RequestAPI', ['$q', '$http', 'User', ($q, $http, User)->

	RequestAPI = {}

	RequestAPI.get = (opts)->
		defer = $q.defer()

		productId = opts.productId
		productId = if _.isUndefined(productId) then "" else productId
		
		params =
			"customerId": User.getId()
			"productId" : productId
			"page" : opts.page
			"displayLimit" : 5
			"openStatus" : opts.openStatus

		$http.post 'functions/getCustomerRequests', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestAPI
]