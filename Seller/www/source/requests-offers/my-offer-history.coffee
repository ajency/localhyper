angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'RequestsAPI', 'OfferHistoryAPI', '$ionicModal'
	, ($scope, App, RequestsAPI, OfferHistoryAPI, $ionicModal)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			page: 0
			canLoadMore: true

			requestDetails:
				modal: null
				data: {}
				display: 'noError'
				errorType: ''
				requestId: null
				offerPrice: ''
				reply: 
					button: true
					text: ''
				deliveryTime:
					display: false
					value: 1
					unit: 'hr'
					unitText: 'Hour'
					setDuration : ->
						if !_.isNull @value
							switch @unit
								when 'hr'
									@unitText = if @value is 1 then 'Hour' else 'Hours'
								when 'day'
									@unitText = if @value is 1 then 'Day' else 'Days'

					done : ->
						if _.isNull(@value)
							@value = 1
							@unit = 'hr'
							@unitText = 'Hour'
						@display = false
						App.resize()

			incrementPage : ->
				$scope.$broadcast 'scroll.refreshComplete'
				@page = @page + 1
				
			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onSuccess : (data)->
				@display = 'noError'
				offerhistory = data
				if offerhistory.length > 0
					@canLoadMore = true
					@requests = @requests.concat(offerhistory)	
				else
					@canLoadMore = false

			onError: (type)->
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			onTapToRetry : ->
				@display = 'error'
				@canLoadMore = true
				@page = 0

			onPullToRefresh : ->
				@requests = []
				@page = 0
				@showOfferHistory()

			onInfiniteScroll : ->
				@showOfferHistory()
				
			showOfferHistory : ()->
				OfferHistoryAPI.offerhistory
					page: @page
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@incrementPage()
					@onScrollComplete()

			init : ->
				@loadOfferDetails()

			loadOfferDetails : ->
				$ionicModal.fromTemplateUrl 'views/requests-offers/offer-history-details.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@requestDetails.modal = modal

			show : ->
				view.modal.show()

			showRequestDetails : (request)->
				@requestDetails.data = request
				@requestDetails.modal.show()	
	
]	

.controller 'EachRequestTimeCtrl', ['$scope', ($scope)->
	#Request time
	iso = $scope.request.createdAt.iso
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

	$scope.request.timeStr = timeStr
]
				



