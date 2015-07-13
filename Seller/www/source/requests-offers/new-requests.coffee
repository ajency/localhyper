angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', ($scope, App, RequestsAPI)->

	$scope.view = 
		display: 'loader'
		errorType: ''
		requests: []

		init : ->
			@getRequests()

		getRequests : ->
			RequestsAPI.getAll()
			.then (data)=>
				console.log data
				@onSuccess data
			, (error)=>
				@onError error

		onSuccess : (data)->
			@display = 'noError'
			@requests = data.requests
		
		onError: (type)->
			@display = 'error'
			@errorType = type

		onTapToRetry : ->
			@display = 'loader'
			@getRequests()

	
	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]