angular.module 'LocalHyper.requestsOffers'


.controller 'SuccessfulOffersCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal'
	, '$timeout', '$rootScope', 'CDialog', '$ionicPlatform', 'DeliveryTime'
	, '$ionicLoading', 'CToast', 'CSpinner', 'RequestsAPI'
	, ($scope, App, OffersAPI, $ionicModal, $timeout, $rootScope, CDialog
	, $ionicPlatform, DeliveryTime, $ionicLoading, CToast, CSpinner, RequestsAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			page: 0
			canLoadMore: true
			refresh: false
			gotAllOffers: false
			noAcceptedOffers: false
			deliveryTime: DeliveryTime

			sortBy: 'updatedAt'
			sortName: 'Recent Offers'
			descending: true

			filter:
				modal: null
				excerpt: ''
				selected: []
				originalAttrs: []
				attributes: [
					{name: 'Pending delivery', value: 'pending_delivery', selected: false}
					{name: 'Sent for delivery', value: 'sent_for_delivery', selected: false}
					{name: 'Failed delivery', value: 'failed_delivery', selected: false}
					{name: 'Successful delivery', value: 'successful', selected: false}]

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/successful-offer-filter.html', 
						scope: $scope,
						animation: 'slide-in-up'
						hardwareBackButtonClose: false
					.then (modal)=>
						@modal = modal

				noChangeInSelection : ->
					_.isEqual _.sortBy(@originalAttrs), _.sortBy(@attributes)

				openModal : ->
					@originalAttrs = JSON.parse JSON.stringify(@attributes)
					@modal.show()

				closeModal : ->
					if @noChangeInSelection()
						@modal.hide()
					else
						msg = 'Your filter selection will go away'
						CDialog.confirm 'Exit Filter?', msg, ['Exit Anyway', 'Apply & Exit']
						.then (btnIndex)=>
							switch btnIndex
								when 1
									@attributes = @originalAttrs
									@modal.hide()
								when 2
									@onApply()

				clearFilters : ->
					@selected = []
					_.each @attributes, (attr)-> attr.selected = false

				onApply : ->
					if @noChangeInSelection()
						@modal.hide()
					else
						_.each @attributes, (attr)=>
							if attr.selected
								if !_.contains @selected, attr.value
									@selected.push attr.value
							else
								@selected = _.without @selected, attr.value
						
						@setExcerpt()
						@modal.hide()
						$scope.view.reFetch()

				setExcerpt : ->
					filterNames = []
					_.each @selected, (val)=>
						attribute = _.filter @attributes, (attr)-> attr.value is val
						filterNames.push attribute[0].name
					@excerpt = filterNames.join ', '

			
			offerDetails:
				modal: null
				showExpiry : false
				data: {}
				pendingOfferId: ""
				showChange: true
				failedDelivery: 
					display: false
					reason: ''

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/successful-offer-details.html', 
						scope: $scope,
						animation: 'slide-in-up' 
						hardwareBackButtonClose: true
					.then (modal)=>
						@modal = modal
				
				show : (request, show=true)->
					@data = request
					@data.deliveryStatus = request.request.status
					@showChange = true
					@checkIfFailedDelivery()
					@modal.show() if show
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
						@show requests[index], false
						@pendingOfferId = ""

				onDeliveryStatusChange : ->
					@failedDelivery.display = @data.deliveryStatus is 'failed_delivery'

				checkIfFailedDelivery : ->
					if @data.deliveryStatus is 'failed_delivery'
						@failedDelivery.display = true
						@failedDelivery.reason = @data.request.failedDeliveryReason
					else
						@failedDelivery.display = false
						@failedDelivery.reason = ''

				onUpdateCancel : ->
					@data.deliveryStatus = @data.request.status
					@checkIfFailedDelivery()
					@showChange = true

				updateDeliveryStatus : ->
					if @data.deliveryStatus is 'failed_delivery'
						if @failedDelivery.reason is ''
							CToast.show 'Please provide reason for delivery failure'
							return

					params = 
						"requestId": @data.request.id
						"status": @data.deliveryStatus
						"failedDeliveryReason": @failedDelivery.reason

					CSpinner.show '', 'Please wait...'
					RequestsAPI.updateRequestStatus params
					.then =>
						@data.request.status = @data.deliveryStatus
						@data.request.failedDeliveryReason = @failedDelivery.reason
						@showChange = true
						CToast.showLongBottom 'Delivery status has been updated. '+
						'Customer will be notified about the status update.'
					, (error)->
						CToast.show 'Failed to update status, please try again'
					.finally ->
						CSpinner.hide()

			
			init : ->
				@offerDetails.loadModal()
				@filter.loadModal()

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			autoFetch : ->
				@page = 0
				@requests = []
				@gotAllOffers = false
				@noAcceptedOffers = false
				@showOfferHistory()

			reFetch : (refresh=true)->
				@refresh = refresh
				@page = 0
				@requests = []
				@canLoadMore = true
				@gotAllOffers = false
				@noAcceptedOffers = false
				$timeout =>
					@onScrollComplete()

			showSortOptions : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/requests-offers/successful-offer-sort.html'
					hideOnStateChange: true

			showOfferHistory : ->
				params = 
					page: @page
					acceptedOffers: true
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
					@noAcceptedOffers = true if _.size(@requests) is 0

				@gotAllOffers = true if !@canLoadMore
				@offerDetails.handlePendingOffer()

			onError: (type)->
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			onPullToRefresh : ->
				@refresh = true
				@page = 0
				@canLoadMore = true
				@gotAllOffers = false
				@noAcceptedOffers = false
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
					when 'deliveryDate'
						if @sortBy isnt 'deliveryDate'
							@sortBy = 'deliveryDate'
							@sortName = sortName
							@descending = descending
							@reFetch()
						else if @descending isnt descending
							@sortBy = 'deliveryDate'
							@sortName = sortName
							@descending = descending
							@reFetch()


		onDeviceBack = ->
			filter = $scope.view.filter
			if $('.loading-container').hasClass 'visible'
				$ionicLoading.hide()
			else if filter.modal.isShown()
				filter.closeModal()
			else
				App.goBack -1

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
		
		$scope.$on 'modal.hidden', ->
			$scope.view.offerDetails.pendingOfferId = ""
			$timeout ->
				$scope.view.offerDetails.showExpiry = false
			, 1000
		
		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'accepted_offer'
				App.scrollTop()
				$scope.view.autoFetch()

		$scope.$on '$ionicView.enter', ->
			#Handle notification click for accepted offer
			offerId = OffersAPI.acceptedOfferId 'get'
			$scope.view.offerDetails.onNotificationClick(offerId) if offerId isnt ''
			OffersAPI.acceptedOfferId 'set', ''
]
