angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', 'RequestAPI', '$interval', 'TimeString'
	, 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope'
	, ($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner, CToast, $rootScope)->

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

			cancelRequest: 
				footer: false
				set : ->
					status = $scope.view.request.status
					count  = _.size $scope.view.offers.all
					if status is 'open' and count is 0
						@footer = true
					else
						@footer = false

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
				@cancelRequest.set()

			onError : (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getOffers()

			onRequestExpiry : ->
				console.log 'onRequestExpiry'
				@request.status = 'expired'
				@cancelRequest.set()

			onAcceptOffer : (acceptedOffer)->
				CSpinner.show '', 'Please wait...'
				offerId  = acceptedOffer.id
				offerIds = _.pluck @offers.all, 'id'
				unacceptedOfferIds = _.without offerIds, offerId

				params = 
					"offerId": offerId
					"unacceptedOfferIds": unacceptedOfferIds

				RequestAPI.acceptOffer params
				.then (data)=>
					_.each @offers.all, (offer)=>
						if offer.id is offerId
							offer.status = 'accepted'
							offer.updatedAt = data.offerUpdatedAt
						else 
							offer.status = 'unaccepted'

					@request.status = 'pending_delivery'
					$rootScope.$broadcast 'offer:accepted'
					CToast.show 'Thank you for accepting the offer. Seller will contact you soon.'

				, (error)->
					CToast.show 'Request failed, please try again'
				.finally ->
					CSpinner.hide()
					App.resize()

			onCancelRequest : ->
				CSpinner.show '', 'Please wait...'
				RequestAPI.updateRequestStatus
					"requestId": @request.id
					"status": "cancelled"
				.then =>
					@request.status = 'cancelled'
					@cancelRequest.set()
					$rootScope.$broadcast 'request:cancelled'
					CToast.show 'Your request has been cancelled'
				, (error)->
					CToast.show 'Cancellation failed, please try again'
				.finally ->
					CSpinner.hide()
					App.resize()

			callSeller : (sellerNumber)->
				telURI = "tel:#{sellerNumber}"
				document.location.href = telURI

		
		$scope.$on '$destroy', ->
			$interval.cancel $scope.view.interval
]


.controller 'EachOfferTimeCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->

	#Delivery time
	deliveryTime = $scope.offer.deliveryTime
	value = deliveryTime.value
	switch deliveryTime.unit
		when 'hr'
			unit = if value is 1 then 'hr' else 'hrs'
		when 'day'
			unit = if value is 1 then 'day' else 'days' 

	$scope.offer.deliveryTimeStr = "#{value} #{unit}"

	getDeliveryTimeLeft = (obj)->
		hours     = if deliveryTime.unit is 'hr' then value else value*24
		format    = 'DD/MM/YYYY HH:mm:ss'
		updatedAt = moment(obj.iso).format format
		totalTime = moment(updatedAt, format).add hours, 'h'
		timeLeft  = totalTime.diff moment()
		duration  = moment.duration timeLeft
		daysLeft  = parseInt duration.asDays().toFixed(0)
		hoursLeft = parseInt duration.asHours().toFixed(0)
		minsLeft  = parseInt duration.asMinutes().toFixed(0)
		if minsLeft < 60
			min = if minsLeft is 1 then 'min' else 'mins'
			str = if minsLeft >= 0 then "#{minsLeft} #{min}" else "0"
		else if hoursLeft < 24
			hr = if hoursLeft is 1 then 'hr' else 'hrs'
			str = "#{hoursLeft} #{hr}"
		else
			day = if daysLeft is 1 then 'day' else 'days'
			str = "#{daysLeft} #{day}"
		str
	
	#Offer & left delivery time
	setTime = ->
		$scope.offer.deliveryTimeLeftStr = getDeliveryTimeLeft $scope.offer.updatedAt
		$scope.offer.timeStr = TimeString.get $scope.offer.createdAt

	setTime()
	interval = $interval setTime, 60000
	$scope.$on '$destroy', ->
		$interval.cancel interval
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

