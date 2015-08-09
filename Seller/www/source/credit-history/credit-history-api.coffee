angular.module 'LocalHyper.creditHistory'


.factory 'CreditHistoryAPI', ['$q', '$http', 'User', ($q, $http, User)->

	CreditHistoryAPI = {}

	CreditHistoryAPI.getAll = (param)->
		defer = $q.defer()
		params = 
			"sellerId": User.getId()
			"displayLimit" : param.displayLimit
			"page" : param.page

		$http.post 'functions/getCreditHistory', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error
		defer.promise
		
	CreditHistoryAPI
]