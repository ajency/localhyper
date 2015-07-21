angular.module 'LocalHyper.requestsOffers'


.factory 'OfferHistoryAPI', ['$q', '$http', 'User', '$timeout', ($q, $http, User, $timeout)->

	OfferHistoryAPI = {}

	OfferHistoryAPI.offerhistory = (opts)->

		user = User.getCurrent()
		console.log('userid'+user.id)

		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"sellerId": user.id
			"page": opts.page
			"displayLimit" : "10"
			

		$http.post 'functions/getSellerOffers', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise


	OfferHistoryAPI
]

