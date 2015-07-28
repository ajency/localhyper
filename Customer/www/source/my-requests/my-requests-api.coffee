angular.module 'LocalHyper.myRequests'


.factory 'MyRequestsAPI', ['$q', '$http', 'User', '$timeout', ($q, $http, User, $timeout)->

	MyRequestsAPI = {}

	MyRequestsAPI.getOpenRequests = (opts)->

		
		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"customerId" : user.id,
			"productId" : "",
			"page" : opts.page,
			"displayLimit" : 3,
			"openStatus" : true
			
		$http.post 'functions/getCustomerRequests', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	MyRequestsAPI
]

