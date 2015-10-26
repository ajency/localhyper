angular.module 'LocalHyper.requestsOffers'


.factory 'OffersAPI', ['$q', '$http', 'User', 'App', ($q, $http, User, App)->

	OffersAPI = {}
	acceptedOfferId = ''

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
		user = User.getCurrent()

		params = 
			"sellerId": user.id
			"sellerGeoPoint": user.get 'addressGeoPoint'
			"page": opts.page
			"displayLimit" : opts.displayLimit
			"acceptedOffers": opts.acceptedOffers
			"selectedFilters" : opts.selectedFilters
			"sortBy" : opts.sortBy
			"descending" : opts.descending
			
		$http.post 'functions/getSellerOffers', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			App.erro(error,params,'getSellerOffers')
			defer.reject error

		defer.promise

	OffersAPI.getAcceptedOfferCount = ->
		defer = $q.defer()
		params = "sellerId": User.getId()

		$http.post 'functions/getAcceptedOfferCount', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	OffersAPI.acceptedOfferId = (action, id)->
		switch action
			when 'set'
				acceptedOfferId = id
			when 'get'
				acceptedOfferId

	OffersAPI
]
