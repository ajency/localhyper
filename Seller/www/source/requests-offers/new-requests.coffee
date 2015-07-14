angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'Push'
	, ($scope, App, RequestsAPI, $rootScope, $ionicModal, Push)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			requestIds: []

			requestDetails:
				modal: null
				display: 'loader'
				errorType: ''
				details: {}

				get : ->
					@display = 'loader'
					RequestsAPI.getDetails()
					.then (data)=>
						@display = 'noError'
						@details = data
					, (type)=>
						@display = 'error'
						@errorType = type

			init : ->
				Push.register()
				@getRequests()
				@loadRequestDetails()

			loadRequestDetails : ->
				$ionicModal.fromTemplateUrl 'views/requests-offers/request-details.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@requestDetails.modal = modal

			getRequests : ->
				RequestsAPI.getNotifications()
				.then (requestIds)=>
					@requestIds = requestIds
					notifications = _.size requestIds
					if notifications > 0
						App.notification.badge = true
						App.notification.count = notifications
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

			isNew : (requestId)->
				_.contains @requestIds, requestId

			onTapToRetry : ->
				@display = 'loader'
				@getRequests()

			showRequestDetails : (newR)->
				console.log newR
				# @requestDetails.modal.show()
				# @requestDetails.get()


		$rootScope.$on 'on:new:request', ->
			$scope.view.getRequests()
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]


.controller 'EachRequestCtrl', ['$scope', ($scope)->

	# if _.contains $scope.view.requestIds, $scope.request.id
	# 	$scope.request.newAlert = 
	# 		"background-color": "#F3766D"

	#Request time
	iso = $scope.request.createdAt.iso
	format = 'DD/MM/YYYY HH:mm:ss'
	now = moment().format format
	at = moment(iso).format format
	diff = moment(now, format).diff(moment(at, format))
	duration = moment.duration diff
	minutes = parseInt duration.asMinutes().toFixed(0)
	hours = parseInt duration.asHours().toFixed(0)

	if minutes is 0
		timeStr = 'Just now'
	else if minutes < 60
		min = if minutes is 1 then 'min' else 'mins'
		timeStr = "#{minutes} #{min} ago"
	else
		hr = if hours is 1 then 'hr' else 'hrs'
		timeStr = "#{hours} #{hr} ago"

	$scope.request.timeStr = timeStr
]

