angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal'
	, '$timeout', '$rootScope', 'CSpinner', 'RequestsAPI', '$ionicPlatform', '$ionicLoading'
	, ($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, CSpinner
	, RequestsAPI, $ionicPlatform, $ionicLoading)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			page: 0
			canLoadMore: true
			refresh: false

			sortBy: 'updatedAt'
			sortName: 'Recent Activity'
			descending: true

			filter:
				open: false
				excerpt: ''
				selected: []
				originalAttrs: []
				attributes: [
					{name: 'Open offers', value: 'open', selected: false}
					{name: 'Unaccepted offers', value: 'unaccepted', selected: false}]

				showOptions : ->
					@open = true
					@originalAttrs = JSON.parse JSON.stringify(@attributes)
					$ionicLoading.show
						scope: $scope
						templateUrl: 'views/requests-offers/offer-history-filter.html'
						hideOnStateChange: true

				setExcerpt : ->
					filterNames = []
					_.each @selected, (val)=>
						attribute = _.filter @attributes, (attr)-> attr.value is val
						filterNames.push attribute[0].name
					@excerpt = filterNames.join ', '

				onApply : ->
					@open = false
					$ionicLoading.hide()

					_.each @attributes, (attr)=>
						if attr.selected
							if !_.contains @selected, attr.value
								@selected.push attr.value
						else
							@selected = _.without @selected, attr.value
					
					@setExcerpt()
					$scope.view.reFetch()

				noChangeInSelection : ->
					_.isEqual _.sortBy(@originalAttrs), _.sortBy(@attributes)

				onHide : ->
					if @open and !@noChangeInSelection()
						@attributes = @originalAttrs
					@open = false


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
					index = _.findIndex requests, (request)=> request.request.id is requestId
					if index is -1
						@pendingRequestId = requestId
						@modal.show()
					else
						@show requests[index]

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

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			autoFetch : ->
				@page = 0
				@requests = []
				@showOfferHistory()

			reFetch : (refresh=true)->
				@refresh = refresh
				@page = 0
				@requests = []
				@canLoadMore = true
				$timeout =>
					@onScrollComplete()

			showSortOptions : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/requests-offers/offer-history-sort.html'
					hideOnStateChange: true

			showOfferHistory : ->
				params = 
					page: @page
					acceptedOffers: false
					displayLimit: 3
					sortBy: @sortBy
					descending: @descending
					selectedFilters: @filter.selected

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
						@onScrollComplete() 

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

			onSort : (sortBy, sortName, descending)->
				$ionicLoading.hide()

				switch sortBy
					when 'updatedAt'
						if @sortBy isnt 'updatedAt'
							@sortBy = 'updatedAt'
							@sortName = sortName
							@descending = descending
							@reFetch()
					when 'distance'
						if @sortBy isnt 'distance'
							@sortBy = 'distance'
							@sortName = sortName
							@descending = descending
							@reFetch()
					when 'offerPrice'
						if @sortBy isnt 'offerPrice'
							@sortBy = 'offerPrice'
							@sortName = sortName
							@descending = descending
							@reFetch()
						else if @descending isnt descending
							@sortBy = 'offerPrice'
							@sortName = sortName
							@descending = descending
							@reFetch()
					when 'expiryTime'
						if @sortBy isnt 'expiryTime'
							@sortBy = 'expiryTime'
							@sortName = sortName
							@descending = descending
							@reFetch()
						else if @descending isnt descending
							@sortBy = 'expiryTime'
							@sortName = sortName
							@descending = descending
							@reFetch()


		onDeviceBack = ->
			if $('.loading-container').hasClass 'visible'
				$scope.view.filter.open = false
				$ionicLoading.hide()
			else
				App.goBack -1

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
		
		$scope.$on 'modal.hidden', ->
			$scope.view.offerDetails.pendingRequestId = ""
			$timeout ->
				$scope.view.offerDetails.showExpiry = false
			, 1000

		$rootScope.$on 'make:offer:success', ->
			App.scrollTop()
			$scope.view.autoFetch()

		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			switch payload.type
				when 'cancelled_request'
					App.scrollTop()
					$scope.view.autoFetch()
				when 'accepted_offer'
					offerId = payload.id
					$scope.view.offerDetails.removeRequestCard offerId

		$scope.$on '$ionicView.enter', ->
			#Handle notification click for cancelled request
			requestId = RequestsAPI.cancelledRequestId 'get'
			$scope.view.offerDetails.onNotificationClick(requestId) if requestId isnt ''
			RequestsAPI.cancelledRequestId 'set', ''
]


