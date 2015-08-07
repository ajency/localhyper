angular.module 'LocalHyper.creditHistory'


.factory 'creditHistoryAPI', ['$q', '$http', ($q, $http)->

	creditHistoryAPI = {}
	

	creditHistoryAPI.getCreditBalance = ->
		defer = $q.defer()
		$http.post 'functions/getCreditBalance', "sellerId": "hay0Mhspc1"
		.then (data)->
			defer.resolve allCategories = data.data.result
		, (error)->
			defer.reject error
		defer.promise


	creditHistoryAPI	

	
]