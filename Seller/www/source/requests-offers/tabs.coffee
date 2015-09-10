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

	link: (scope, el, attrs)->
		$timeout ->
			$('.loading-container').on 'click', (event)->
				isBackdrop = $(event.target).hasClass 'loading-container'
				if isBackdrop
					$ionicLoading.hide()
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

			# totalStr = '2015/08/06 12:20:00'

			$(el).countdown totalStr, (event)->
				$(el).html event.strftime('%-H:%-M:%-S')

			.on 'finish.countdown', (event)->
				scope.$apply ->
					scope.countDownFinish()
]


.factory 'DeliveryTime', [->

	DeliveryTime = 

		humanize : (obj)->
			if !_.isUndefined obj
				value = obj.value
				switch obj.unit
					when 'hr'
						unitText = if value is 1 then 'Hour' else 'Hours'
					when 'day'
						unitText = if value is 1 then 'Day' else 'Days'

				"#{value} #{unitText}"

		left : (timeObj)->
			format    = 'DD/MM/YYYY HH:mm:ss'
			deliveryDate = moment(timeObj.iso).format format
			timeLeft  = moment(deliveryDate, format).diff moment()
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


.factory 'LowestPrice', [->

	LowestPrice = {}

	LowestPrice.get = (request)->
		platformPrice = request.platformPrice
		mrp = request.product.mrp
		onlinePrice = request.onlinePrice
		priceArray = []
		priceLabel = []
		if platformPrice isnt ''
			priceArray.push(platformPrice) 
			priceLabel.push('Platform price')
		if mrp isnt '' 
			priceArray.push(mrp) 
			priceLabel.push('Mrp')
		if onlinePrice isnt '' 
			priceArray.push(onlinePrice)
			priceLabel.push('Online price')
		
		minPrice = _.min priceArray
		request.lowestPrice = minPrice
		request.lowestPriceLabel = priceLabel[priceArray.indexOf(minPrice)]

	LowestPrice
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

