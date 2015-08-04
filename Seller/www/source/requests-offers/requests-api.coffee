angular.module 'LocalHyper.requestsOffers'


.factory 'RequestsAPI', ['$q', '$http', 'User', '$timeout', ($q, $http, User, $timeout)->

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

	RequestsAPI.getSingleRequest = (requestId)->
		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"requestId": requestId
			"sellerId": user.id
			"sellerGeoPoint": user.get 'addressGeoPoint'

		$http.post 'functions/getSingleRequest', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI.getNotifications = ->
		defer = $q.defer()
		params = 
			"userId": User.getId()
			"type": "Request"

		$http.post 'functions/getUnseenNotifications', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI.updateStatus = (requestId)->
		defer = $q.defer()

		params = 
			"notificationTypeId": requestId
			"recipientId": User.getId()
			"notificationType" : "Request"
			"hasSeen": true

		$http.post 'functions/updateNotificationStatus', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI
]

