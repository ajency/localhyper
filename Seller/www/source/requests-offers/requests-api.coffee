angular.module 'LocalHyper.requestsOffers'


.factory 'RequestsAPI', ['$q', '$http', 'User', ($q, $http, User)->

	RequestsAPI = {}

	RequestsAPI.getAll = ->
		defer = $q.defer()
		user = User.getCurrent()
		params = 
			"sellerId": user.id
			"city": user.get 'city'
			"area": user.get 'area'
			"sellerLocation": "default"
			"sellerRadius": "default"

		$http.post 'functions/getNewRequests', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI
]