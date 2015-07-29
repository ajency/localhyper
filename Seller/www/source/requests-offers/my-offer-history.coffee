angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'RequestsAPI', 'OfferHistoryAPI', '$ionicModal', '$timeout'
	, ($scope, App, RequestsAPI, OfferHistoryAPI, $ionicModal, $timeout)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			page: 0
			canLoadMore: true
			refresh: false

			requestDetails:
				modal: null
				showExpiry : false
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
				console.log('offer history')
				console.log(data)
				offerhistory = data
				
				if offerhistory.length > 0
					if _.size(offerhistory) < 3 then @canLoadMore = false
					else @onScrollComplete()
					if @refresh then @requests = offerhistory
					else @requests = @requests.concat(offerhistory)
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
				@refresh = true
				@canLoadMore = true
				@page = 0
				@showOfferHistory()

			onInfiniteScroll : ->
				@refresh = false
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
				@requestDetails.showExpiry = true

		$scope.$on 'modal.hidden', ->
			$timeout ->
				$scope.view.requestDetails.showExpiry = false
			, 1000
	
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


