angular.module 'LocalHyper.requestsOffers', []


.directive 'ajRemoveBoxShadow', ['$timeout', ($timeout)->

	restrict: 'A'
	link: (scope, el, attrs)->
		$timeout ->
			$('.bar-header').removeClass 'bar-light'
]


.directive 'ajAddBoxShadow', ['$timeout', ($timeout)->

	restrict: 'A'
	link: (scope, el, attrs)->
		$timeout ->
			$('.bar-header').addClass 'bar-light'
]


.directive 'ajLoadingBackDrop', ['$timeout', '$ionicLoading', ($timeout, $ionicLoading)->

	restrict: 'A'
	scope:
		onLoadingHidden: '&'

	link: (scope, el, attrs)->
		
		$timeout ->
			$('.loading-container').on 'click', (event)->
				isBackdrop = $(event.target).hasClass 'loading-container'
				if isBackdrop
					$ionicLoading.hide()
					scope.$apply ->
						scope.onLoadingHidden()
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


.factory 'TimeString', [->

	TimeString = {}

	TimeString.get = (obj)->
		iso       = obj.iso
		format    = 'DD/MM/YYYY HH:mm:ss'
		now       = moment().format format
		createdAt = moment(iso).format format
		diff      = moment(now, format).diff(moment(createdAt, format))
		duration  = moment.duration diff
		minutes   = parseInt duration.asMinutes().toFixed(0)
		hours     = parseInt duration.asHours().toFixed(0)
		days      = parseInt duration.asDays().toFixed(0)
		weeks     = parseInt duration.asWeeks().toFixed(0)

		if minutes < 1 then timeStr = 'Just now'
		else if minutes < 60
			min = if minutes is 1 then 'min' else 'mins'
			timeStr = "#{minutes} #{min} ago"
		else if minutes >= 60 and minutes < 1440#(24Hrs)
			hr = if hours is 1 then 'hr' else 'hrs'
			timeStr = "#{hours} #{hr} ago"
		else if minutes >= 1440 and days < 7
			day = if days is 1 then 'day' else 'days'
			timeStr = "#{days} #{day} ago"
		else if days >= 7 and weeks <= 4
			week = if weeks is 1 then 'week' else 'weeks'
			timeStr = "#{weeks} #{week} ago"
		else
			timeStr = "On #{moment(iso).format('DD-MM-YYYY')}"

		timeStr

	TimeString
]


.controller 'EachRequestTimeCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->

	#Request time
	setTime = ->
		$scope.request.timeStr = TimeString.get $scope.request.createdAt

	setTime()
	interval = $interval setTime, 60000
	$scope.$on '$destroy', ->
		$interval.cancel interval
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'tabs',
			url: "/tab"
			abstract: true
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/requests-offers/tabs.html'

		.state 'new-requests',
			url: '/new-requests'
			parent: 'tabs'
			views: 
				"newRequestsTab":
					controller: 'NewRequestCtrl'
					templateUrl: 'views/requests-offers/new-requests.html'

		.state 'my-offer-history',
			url: '/my-offer-history'
			parent: 'tabs'
			views: 
				"myOfferHistoryTab":
					controller: 'MyOfferHistoryCtrl'
					templateUrl: 'views/requests-offers/my-offer-history.html'

		.state 'successful-offers',
			url: '/successful-offers'
			parent: 'tabs'
			views: 
				"successfulOffersTab":
					controller: 'SuccessfulOffersCtrl'
					templateUrl: 'views/requests-offers/successful-offers.html'
]

