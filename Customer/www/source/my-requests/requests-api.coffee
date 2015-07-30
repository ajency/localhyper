angular.module 'LocalHyper.myRequests'


.factory 'RequestAPI', ['$q', '$http', 'User', ($q, $http, User)->

	RequestAPI = {}
	requestDetails = {}

	RequestAPI.get = (opts)->
		defer = $q.defer()

		productId = opts.productId
		productId = if _.isUndefined(productId) then "" else productId
		
		params =
			"customerId": User.getId()
			"productId" : productId
			"page" : opts.page
			"displayLimit" : opts.displayLimit
			"requestType" : opts.requestType
			"selectedFilters": opts.selectedFilters
			"sortBy" : "updatedAt"
			"descending" : true

		$http.post 'functions/getCustomerRequests', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestAPI.requestDetails = (action, data={})->
		switch action
			when 'set'
				requestDetails = data
			when 'get'
				requestDetails

	RequestAPI.getOffers = (requestId)->
		defer = $q.defer()
		
		params = "requestId": requestId

		$http.post 'functions/getRequestOffers', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestAPI.acceptOffer = (params)->
		defer = $q.defer()

		$http.post 'functions/acceptOffer', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestAPI.updateRequestStatus = (params)->
		defer = $q.defer()

		# requestID: ""
		# "status" : "cancelled"  (accepted status values are : open / cancelled / successful)

		$http.post 'functions/updateRequestStatus', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestAPI
]

