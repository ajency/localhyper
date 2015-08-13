angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', 'RequestAPI', '$interval', 'TimeString'
	, 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope', 'CDialog', '$ionicPopup'
	, ($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner
	, CToast, $rootScope, CDialog, $ionicPopup)->

		$scope.view = 
			request: RequestAPI.requestDetails 'get'
			display: 'loader'
			errorType: ''
			
			address: 
				show: false
				toggle : ->
					@show = !@show
					$timeout -> 
						App.resize()
					, 500

			showComment : (title, comment)->
				$ionicPopup.alert
					title: title
					template: comment
					okText: 'Close'
					okType: 'button-assertive'

			cancelRequest: 
				footer: false
				set : ->
					status = $scope.view.request.status
					count  = _.size $scope.view.offers.all
					if status is 'open' and count is 0
						@footer = true
					else
						@footer = false
			
			offers:
				id: null
				display: 'none'
				errorType: ''
				all: []
				limitTo: 1

				showAll : ->
					@limitTo = 100
					App.resize()

				get: ->
					@display = 'loader'
					RequestAPI.getOffers $scope.view.request.id
					.then (offers)=>
						@onSuccess offers
					, (error)=>
						@onError error
					.finally ->
						App.resize()

				getSilently : ->
					RequestAPI.getOffers $scope.view.request.id
					.then (offers)=>
						@onSuccess offers

				onSuccess : (offers)->
					console.log offers
					@display = 'noError'
					@all = offers
					@markOffersAsSeen()
					$scope.view.cancelRequest.set()

				onError : (type)->
					@display = 'error'
					@errorType = type

				markOffersAsSeen : ->
					RequestAPI.isNotificationSeen $scope.view.request.id
					.then (obj)=>
						if !obj.hasSeen
							offerIds = _.pluck @all, 'id'
							RequestAPI.updateNotificationStatus offerIds
							.then =>
								_.each @all, (offer)-> App.notification.decrement()

			

			init : ->
				if _.has(@request, 'pushOfferId')
					@offers.id = @request.pushOfferId
					@getRequestForOffer() 
				else
					@display = 'noError'
					@setRequestTime()
					@offers.get()

			getRequestForOffer : ->
				@display = 'loader'
				RequestAPI.getRequestForOffer @offers.id
				.then (request)=>
					@onSuccess request
				, (error)=>
					@onError error
				.finally ->
					App.resize()

			onSuccess : (request)->
				@display = 'noError'
				@request = request
				@setRequestTime()
				@offers.get()

			onError : (type)->
				@display = 'error'
				@errorType = type

			setRequestTime : ->
				set = => 
					@request.timeStr = TimeString.get @request.createdAt
				set()
				@interval = $interval =>
					set()
				, 60000

			onRequestExpiry : ->
				console.log 'onRequestExpiry'
				@request.status = 'expired'
				@cancelRequest.set()

			onAcceptOffer : (acceptedOffer)->
				CSpinner.show '', 'Please wait...'
				offerId  = acceptedOffer.id
				offerIds = _.pluck @offers.all, 'id'
				unacceptedOfferIds = _.without offerIds, offerId

				params = 
					"offerId": offerId
					"unacceptedOfferIds": unacceptedOfferIds

				RequestAPI.acceptOffer params
				.then (data)=>
					_.each @offers.all, (offer)=>
						if offer.id is offerId
							offer.status = 'accepted'
							offer.updatedAt = data.offerUpdatedAt
						else 
							offer.status = 'unaccepted'

					@request.status = 'pending_delivery'
					$rootScope.$broadcast 'offer:accepted'
					CToast.show 'Thank you for accepting the offer. Seller will contact you soon.'

				, (error)->
					CToast.show 'Request failed, please try again'
				.finally ->
					CSpinner.hide()
					App.resize()

			onCancelRequest : ->
				CDialog.confirm 'Cancel Request', 'Are you sure you wish to cancel this request?', ['Yes', 'No']
				.then (btnIndex)=>
					if btnIndex is 1
						CSpinner.show '', 'Please wait...'
						RequestAPI.updateRequestStatus
							"requestId": @request.id
							"status": "cancelled"
						.then =>
							@request.status = 'cancelled'
							@cancelRequest.set()
							$rootScope.$broadcast 'request:cancelled'
							CToast.show 'Your request has been cancelled'
						, (error)->
							CToast.show 'Cancellation failed, please try again'
						.finally ->
							CSpinner.hide()
							App.resize()

			callSeller : (sellerNumber)->
				telURI = "tel:#{sellerNumber}"
				document.location.href = telURI


		inAppNotificationEvent = $rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				if _.size($scope.view.offers.all) is 0 then $scope.view.offers.get()
				else $scope.view.offers.getSilently()
		
		$scope.$on '$destroy', ->
			inAppNotificationEvent()
			$interval.cancel $scope.view.interval

		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
]


.controller 'EachOfferTimeCtrl', ['$scope', '$interval', 'TimeString', 'DeliveryTime'
	, ($scope, $interval, TimeString, DeliveryTime)->

		$scope.offer.deliveryTimeStr = DeliveryTime.humanize $scope.offer.deliveryTime
		
		#Offer time & left delivery time
		setTime = ->
			$scope.offer.timeStr = TimeString.get $scope.offer.createdAt
			$scope.offer.deliveryTimeLeftStr = DeliveryTime.left $scope.offer.updatedAt

		setTime()
		interval = $interval setTime, 60000
		$scope.$on '$destroy', ->
			$interval.cancel interval
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

