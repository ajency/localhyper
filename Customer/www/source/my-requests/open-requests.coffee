angular.module 'LocalHyper.myRequests'

.controller 'OpenRequestCtrl', ['$scope', 'App', 'RequestAPI'
	, ($scope, App, RequestAPI )->

		$scope.view = 
			display: 'loader'
			errorType: ''
			openRequests: []
			page: 0
			canLoadMore: true

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			incrementPage : ->
				$scope.$broadcast 'scroll.refreshComplete'
				@page = @page + 1
							
			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onPullToRefresh : ->
				@openRequests = []
				@page = 0
				@getMyOffers()

			onTapToRetry : ->
				@canLoadMore = true
				@display = 'error'
				@page = 0
				
			getMyOffers : ()->
				RequestAPI.get
					page: @page
					openStatus: true
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@incrementPage()
					@onScrollComplete()
					
			onSuccess : (data)->
				@display = 'noError'
				console.log('open request')
				console.log(data)
				openRequest = data
				if openRequest.length > 0
					@canLoadMore = true
					@openRequests = @openRequests.concat(openRequest)	
				else
					@canLoadMore = false


			onError: (type)->
				@canLoadMore = false
				@display = 'error'
				@errorType = type

			init : ->
				# @getMyOffers()	

			onInfiniteScroll : ->
				@getMyOffers()
			
]

.controller 'EachRequestTimeCtrl', ['$scope', ($scope)->
	#Request time
	iso = $scope.openRequest.createdAt.iso
	format = 'DD/MM/YYYY HH:mm:ss'
	now = moment().format format
	at = moment(iso).format format
	diff = moment(now, format).diff(moment(at, format))
	duration = moment.duration diff
	minutes = parseInt duration.asMinutes().toFixed(0)
	hours = parseInt duration.asHours().toFixed(0)

	if minutes <= 5
		timeStr = 'Just now'
	else if minutes < 60
		min = if minutes is 1 then 'min' else 'mins'
		timeStr = "#{minutes} #{min} ago"
	else
		hr = if hours is 1 then 'hr' else 'hrs'
		timeStr = "#{hours} #{hr} ago"

	$scope.openRequest.timeStr = timeStr
]



