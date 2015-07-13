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

		createdAt : (at)->
			format = 'DD/MM/YYYY hh:mm'
			now = moment().format format
			at = moment(at).format format
			diff = moment(at, format).diff(moment(now, format))
			duration = moment.duration diff
			parseInt duration.asHours()


	
	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]