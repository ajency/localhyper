angular.module 'LocalHyper.myRequests', []


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


.controller 'EachRequestTimeCtrl', ['$scope', '$interval', ($scope, $interval)->
	#Request time
	setTime = ->
		iso       = $scope.request.createdAt.iso
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

		$scope.request.timeStr = timeStr

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
					templateUrl: 'views/my-requests/tabs.html'

		.state 'open-requests',
			url: '/open-requests'
			parent: 'tabs'
			views: 
				"openRequestsTab":
					controller: 'OpenRequestCtrl'
					templateUrl: 'views/my-requests/open-requests.html'

		.state 'requests-history',
			url: '/requests-history'
			parent: 'tabs'
			views: 
				"requestHistoryTab":
					controller: 'RequestsHistoryCtrl'
					templateUrl: 'views/my-requests/requests-history.html'
]



