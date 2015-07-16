angular.module 'LocalHyper.requestsOffers'


.factory 'OffersAPI', ['$q', '$http', ($q, $http)->

	OffersAPI = {}

	OffersAPI.makeOffer = (params)->
		defer = $q.defer()

		$http.post 'functions/makeOffer', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise


	OffersAPI
]

