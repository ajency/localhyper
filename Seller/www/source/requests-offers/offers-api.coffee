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

.factory 'OfferHistoryAPI', ['$q', '$http', 'User', '$timeout', ($q, $http, User, $timeout)->

	OfferHistoryAPI = {}

	OfferHistoryAPI.offerhistory = (opts)->
		user = User.getCurrent()
		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"sellerId": user.id
			"page": opts.page
			"displayLimit" : "10"
			"acceptedOffers": false
			"selectedFilters" : []
			"sortBy" : "updatedAt"
			"descending" : true

			
		$http.post 'functions/getSellerOffers', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	OfferHistoryAPI
]

