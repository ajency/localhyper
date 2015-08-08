angular.module 'LocalHyper.creditHistory'


.factory 'creditHistoryAPI', ['$q', '$http', 'User', ($q, $http, User)->

	creditHistoryAPI = {}
	

	creditHistoryAPI.getCreditHistory = (param)->

		user = User.getCurrent()

		params = 
			"sellerId": user.id
			"displayLimit" : param.displayLimit
			"page" : param.page

		defer = $q.defer()
		$http.post 'functions/getCreditHistory', params
		.then (data)->
			defer.resolve allCategories = data.data.result
		, (error)->
			defer.reject error
		defer.promise
		
	creditHistoryAPI	

	
]