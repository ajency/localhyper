angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal'
	, ($scope, App, RequestsAPI, $rootScope, $ionicModal)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			requestIds: []
			requestDetailsModal: null

			init : ->
				@getRequests()
				@loadRequestDetails()

			loadRequestDetails : ->
				$ionicModal.fromTemplateUrl 'views/requests-offers/request-details.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@requestDetailsModal = modal

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

			onTapToRetry : ->
				@display = 'loader'
				@getRequests()


		$rootScope.$on 'on:new:request', ->
			$scope.view.getRequests()
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]


.controller 'EachRequestCtrl', ['$scope', ($scope)->

	if _.contains $scope.view.requestIds, $scope.request.id
		$scope.request.newAlert = 
			"background-color": "#F3766D"

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

