angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', 'RequestAPI', '$interval', 'TimeString'
	, 'App', '$timeout'
	, ($scope, RequestAPI, $interval, TimeString, App, $timeout)->

		$scope.view = 
			request: RequestAPI.requestDetails 'get'
			display: 'loader'
			errorType: ''
			
			address: 
				show: false
				toggle : ->
					@show = !@show
					$timeout -> 
						App.resize()
					, 500

			comments:
				show: false
				toggle : ->
					@show = !@show
					$timeout -> 
						App.resize()
					, 500
			
			offers:
				all: []
				limitTo: 1
				received: true

			init : ->
				console.log $scope.view.request
				@setRequestTime()
				@getOffers()

			setRequestTime : ->
				set = => 
					@request.timeStr = TimeString.get @request.createdAt
				set()
				@interval = $interval =>
					set()
				, 60000

			onRequestExpiry : ->
				console.log 'onRequestExpiry'

			showAllOffers : ->
				@offers.limitTo = 100
				App.resize()

			getOffers : ->
				RequestAPI.getOffers (@request.id)
				.then (offers)=>
					@onSuccess offers
				, (error)=>
					@onError error
				.finally ->
					App.resize()

			onSuccess : (offers)->
				console.log offers
				@display = 'noError'
				@offers.all = offers

			onError : (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getOffers()

		
		$scope.$on '$destroy', ->
			$interval.cancel $scope.view.interval
]


.controller 'EachOfferTimeCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->
	#Offer time
	setTime = ->
		$scope.offer.timeStr = TimeString.get $scope.offer.createdAt

	setTime()
	interval = $interval setTime, 60000
	$scope.$on '$destroy', ->
		$interval.cancel interval


	#Delivery time
	deliveryTime = $scope.offer.deliveryTime
	value = deliveryTime.value
	switch deliveryTime.unit
		when 'hr'
			unit = if value is 1 then 'hr' else 'hrs'
		when 'day'
			unit = if value is 1 then 'day' else 'days' 

	$scope.offer.deliveryTimeStr = "#{value} #{unit}"
]


.directive 'ajCountDown', ['$timeout', ($timeout)->

	restrict: 'A'
	scope:
		createdAt : '='
		countDownFinish: '&'

	link: (scope, el, attrs)->
		
		$timeout ->
			createdAt = moment(scope.createdAt.iso)
			total = moment(createdAt).add 24, 'hours'
			totalStr = moment(total).format 'YYYY/MM/DD HH:mm:ss'

			# totalStr = '2015/07/29 17:2:00'

			$(el).countdown totalStr, (event)->
				$(el).html event.strftime('%-H:%-M:%-S')

			.on 'finish.countdown', (event)->
				scope.$apply ->
					scope.countDownFinish()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'request-details',
			url: '/request-details'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					templateUrl: 'views/my-requests/request-details.html'
					controller: 'RequestDetailsCtrl'
]

