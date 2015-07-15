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

	RequestsAPI.getById = (id)->
		defer = $q.defer()

		$http.get "classes/Request/#{id}?include=product,brand"#, params
		.then (data)->
			defer.resolve data.data
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI.getNotifications = ->
		defer = $q.defer()
		user = User.getCurrent()
		params = 
			"userId": user.id
			"type": "Request"

		$http.post 'functions/getUnseenNotifications', params
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	RequestsAPI.updateStatus = (requestId)->
		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"notificationTypeId": "#{requestId}"
			"recipientId": "#{user.id}"
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

