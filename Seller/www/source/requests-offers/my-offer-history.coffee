angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal'
	, '$timeout', '$rootScope', '$stateParams', 'CSpinner'
	, ($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, $stateParams, CSpinner)->

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
					@pendingRequestId = requestId
					@modal.show()

				handlePendingRequest : ->
					if @pendingRequestId isnt ""
						requests = $scope.view.requests
						index = _.findIndex requests, (request)=> request.request.id is @pendingRequestId
						if index isnt -1
							@data = requests[index]
							@showExpiry = true
							@pendingRequestId = ""
						else
							@modal.hide()
							CSpinner.show '', 'Sorry, this request has been cancelled'
							$timeout =>
								CSpinner.hide()
							, 2000

				removeRequestCard : (offerId)->
					spliceIndex = _.findIndex $scope.view.requests, (offer)->
						offer.id is offerId
					$scope.view.requests.splice(spliceIndex, 1) if spliceIndex isnt -1



			init : ->
				@offerDetails.loadModal()

			reFetch : ->
				@page = 0
				@requests = []
				@showOfferHistory()

			showOfferHistory : ->
				params = 
					page: @page
					acceptedOffers: false
					displayLimit: 3

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
			switch payload.type
				when 'cancelled_request'
					App.scrollTop()
					$scope.view.reFetch()
				when 'accepted_offer'
					offerId = payload.id
					$scope.view.offerDetails.removeRequestCard offerId
		
		$scope.$on '$ionicView.enter', ->
			#When cancelled request
			requestId = $stateParams.requestId
			$scope.view.offerDetails.onNotificationClick(requestId) if requestId isnt ""
]


