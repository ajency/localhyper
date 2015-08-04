angular.module 'LocalHyper.requestsOffers'


.controller 'SuccessfulOffersCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal'
	, '$timeout', '$rootScope'
	, ($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope)->

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
				pendingOfferId: ""

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/successful-offer-details.html', 
						scope: $scope,
						animation: 'slide-in-up' 
						hardwareBackButtonClose: true
					.then (modal)=>
						@modal = modal
				
				show : (request)->
					@data = request
					@modal.show()
					@showExpiry = true

				onNotificationClick : (offerId)->
					requests = $scope.view.requests
					index = _.findIndex requests, (offer)=> offer.id is offerId
					if index is -1
						@pendingOfferId = offerId
						@modal.show()
					else
						@show requests[index]

				handlePendingOffer : ->
					if @pendingOfferId isnt ""
						requests = $scope.view.requests
						index = _.findIndex requests, (offer)=> offer.id is @pendingOfferId
						@data = requests[index]
						@showExpiry = true
						@pendingOfferId = ""

			init : ->
				@offerDetails.loadModal()

			reFetch : ->
				@page = 0
				@requests = []
				@showOfferHistory()

			showOfferHistory : ->
				params = 
					page: @page
					acceptedOffers: true
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

				@offerDetails.handlePendingOffer()

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
			$scope.view.offerDetails.pendingOfferId = ""
			$timeout ->
				$scope.view.offerDetails.showExpiry = false
			, 1000
		
		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'accepted_offer'
				App.scrollTop()
				$scope.view.reFetch()

		$rootScope.$on 'accepted:offer', (e, obj)->
			$scope.view.offerDetails.onNotificationClick obj.offerId
]
