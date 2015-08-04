angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal'
	, '$timeout', '$rootScope', '$stateParams'
	, ($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, $stateParams)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			page: 0
			canLoadMore: true
			refresh: false

			offerDetails:
				modal: null
				showExpiry : false
				data: {}
				pendingRequestId: ""

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/offer-history-details.html', 
						scope: $scope,
						animation: 'slide-in-up' 
						hardwareBackButtonClose: true
					.then (modal)=>
						@modal = modal
				
				show : (request)->
					@data = request
					@modal.show()
					@showExpiry = true

				onNotificationClick : (requestId)->
					requests = $scope.view.requests
					index = _.findIndex requests, (request)-> request.id is requestId
					if index is -1
						@pendingRequestId = requestId
						@modal.show()
					else 
						@show requests[index]

				handlePendingRequest : ->
					if @pendingRequestId isnt ""
						requests = $scope.view.requests
						index = _.findIndex requests, (request)=> request.request.id is @pendingRequestId
						@data = requests[index]
						@showExpiry = true
						@pendingRequestId = ""

			init : ->
				@offerDetails.loadModal()

			reFetch : ->
				@page = 0
				@requests = []
				@showOfferHistory()

			showOfferHistory : ->
				params = page: @page, displayLimit: 3

				OffersAPI.getSellerOffers params
				.then (data)=>
					console.log data
					@onSuccess data, params.displayLimit
				, (error)=>
					@onError error
				.finally =>
					App.resize()
					@page = @page + 1
					$scope.$broadcast 'scroll.refreshComplete'

			onSuccess : (offerData, displayLimit)->
				@display = 'noError'
				offerDataSize = _.size(offerData)
				if offerDataSize > 0
					if offerDataSize < displayLimit
						@canLoadMore = false
					else
						@canLoadMore = true 
						$scope.$broadcast 'scroll.infiniteScrollComplete'

					if @refresh then @requests = offerData
					else @requests = @requests.concat offerData
				else
					@canLoadMore = false

				@offerDetails.handlePendingRequest()

			onError: (type)->
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			onPullToRefresh : ->
				@refresh = true
				@page = 0
				@canLoadMore = true
				@showOfferHistory()

			onInfiniteScroll : ->
				@refresh = false
				@showOfferHistory()

			onTapToRetry : ->
				@display = 'loader'
				@page = 0
				@canLoadMore = true
		
		
		$scope.$on 'modal.hidden', ->
			$scope.view.offerDetails.pendingRequestId = ""
			$timeout ->
				$scope.view.offerDetails.showExpiry = false
			, 1000

		$rootScope.$on 'make:offer:success', ->
			App.scrollTop()
			$scope.view.reFetch()

		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'cancelled_request'
				App.scrollTop()
				$scope.view.reFetch()

		$scope.$on '$ionicView.enter', ->
			#When cancelled request
			requestId = $stateParams.requestId
			$scope.view.offerDetails.onNotificationClick(requestId) if requestId isnt ""
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


