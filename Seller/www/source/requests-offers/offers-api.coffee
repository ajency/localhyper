angular.module 'LocalHyper.requestsOffers'


.factory 'OffersAPI', ['$q', '$http', 'User', ($q, $http, User)->

	OffersAPI = {}

	OffersAPI.makeOffer = (params)->
		defer = $q.defer()

		$http.post 'functions/makeOffer', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	OffersAPI.getSellerOffers = (opts)->
		defer = $q.defer()

		params = 
			"sellerId": User.getId()
			"page": opts.page
			"displayLimit" : opts.displayLimit
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

	OffersAPI
]