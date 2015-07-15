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
				data: {}
				display: 'noError'
				errorType: ''
				requestId: null

				showModal : (requestId)->
					@requestId = requestId
					@modal.show()
					@get()

				get : ->
					@display = 'loader'
					RequestsAPI.getById @requestId
					.then (request)=>
						console.log request
						@display = 'noError'
						@data = request
						$scope.view.markNotificationAsSeen request.objectId
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

			showRequestDetails : (request)->
				@requestDetails.display = 'noError'
				@requestDetails.data = request
				@requestDetails.modal.show()
				@markNotificationAsSeen request.id

			markNotificationAsSeen : (requestId)->
				index = _.findIndex @requests, (val)-> val.id is requestId
				if index isnt -1
					newRequest = @requests[index].new 
					if newRequest
						RequestsAPI.updateStatus requestId
						.then (data)=>
							App.notification.decrement()
							@requests[index].new = false


		$rootScope.$on 'on:new:request', ->
			$scope.view.getRequests()

		$rootScope.$on 'on:notification:click', (e, obj)->
			$scope.view.requestDetails.showModal obj.payload.id
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]


.controller 'EachRequestCtrl', ['$scope', ($scope)->

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

