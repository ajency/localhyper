angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', 'RequestAPI', '$interval', 'TimeString'
	, ($scope, RequestAPI, $interval, TimeString)->

		$scope.view = 
			request: RequestAPI.requestDetails 'get'
			
			offers:
				all: []
				received: true
				count: 0

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

			getOffers : ->
				RequestAPI.getOffers (@request.id)
				.then (offers)=>
					console.log offers
					@offers.all = offers
		
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
]


.directive 'ajCountDown', ['$timeout', '$parse', ($timeout, $parse)->

	restrict: 'A'
	link: (scope, el, attrs)->
		
		$timeout ->
			createdAt = $parse(attrs.createdAt)(scope)
			total = moment(moment(createdAt.iso)).add 24, 'hours'
			totalStr = moment(total).format 'YYYY/MM/DD HH:mm:ss'

			$(el).countdown totalStr, (event)->
				$(el).html event.strftime('%-H:%-M:%-S')
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