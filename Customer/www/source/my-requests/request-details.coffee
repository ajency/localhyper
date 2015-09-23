angular.module 'LocalHyper.myRequests'


.controller 'RequestDetailsCtrl', ['$scope', 'RequestAPI', '$interval', 'TimeString'
	, 'App', '$timeout', 'CSpinner', 'CToast', '$rootScope', 'CDialog', '$ionicPopup'
	, 'User', '$window', '$ionicLoading', '$ionicPlatform'
	, ($scope, RequestAPI, $interval, TimeString, App, $timeout, CSpinner
	, CToast, $rootScope, CDialog, $ionicPopup, User, $window , $ionicLoading, $ionicPlatform)->

		$scope.view = 
			request: RequestAPI.requestDetails 'get'
			display: 'loader'
			errorType: ''
			pushParams: null
			helpURL: $window.HELP_URL
			
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

			showInfo : ()->
				$ionicPopup.alert
					title: 'Info'
					template: 'Delivery date gets calculate based on customer request accepted and your working days'
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
				display: 'none'
				errorType: ''
				all: []
				limitTo: 1

			
				rate:
					star : ''
					score: 1
					max: 5
					comment: ''
					setScore : (score)->
						rateValue = ['','Poor', 'Average', 'Good', 'Very Good', 'Excellent']
						@star = rateValue[score]
						@score = score

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
					# @markOffersAsSeen()
					$scope.view.cancelRequest.set()

				onError : (type)->
					@display = 'error'
					@errorType = type

				# markOffersAsSeen : ->
				# 	RequestAPI.isOfferNotificationSeen $scope.view.request.id
				# 	.then (obj)=>
				# 		if !obj.hasSeen
				# 			offerIds = _.pluck @all, 'id'
				# 			RequestAPI.updateNotificationStatus offerIds
				# 			.then =>
				# 				_.each @all, (offer)-> App.notification.decrement()

				markAsSeen : (offer)->
					hasSeen = offer.notification.hasSeen
					if !hasSeen
						RequestAPI.updateNotificationStatus [offer.id]
						.then -> 
							App.notification.decrement()
							$rootScope.$broadcast 'get:open:request:count'

				openRatePopup : (seller)->
					if (seller.isSellerRated == false)
						@rate.sellerId = seller.id
						@rate.sellerName = seller.businessName
						@rate.star = 'Poor'
						@rate.score = 1
						@rate.comment = ''
						
						$ionicLoading.show
							scope: $scope
							templateUrl: 'views/my-requests/rate.html'
							hideOnStateChange: true

				rateSeller : ()->
					$ionicLoading.hide()
					CSpinner.show '', 'Submitting your review...'
					RequestAPI.updateSellerRating
						"customerId": User.getId()
						"sellerId": @rate.sellerId
						"ratingInStars": @rate.score
						"comments": @rate.comment
					.then ->
						CToast.show 'Thanks for your feedback'
					, (error)->
						CToast.show 'An error occurred, please try again'
					.finally ->
						CSpinner.hide()

				DeliveryDate :(date)->
					format    = 'DD/MM/YYYY'
					deliveryDate = moment(date).format format
					deliveryDate

				
			init : ->
				if _.has(@request, 'pushOfferId')
					#When new offer
					@pushParams =
						"offerId": @request.pushOfferId
						"requestId": ''
					@getRequestDetails()
				else if _.has(@request, 'pushRequestId')
					#When delivery status change
					@pushParams =
						"offerId": ''
						"requestId": @request.pushRequestId
					@getRequestDetails()
				else
					@display = 'noError'
					@setRequestTime()
					@offers.get()

			getRequestDetails : ->
				@display = 'loader'
				RequestAPI.getRequestDetails @pushParams
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
					"acceptedDateIST" : 
						"__type": "Date"
						"iso": new Date 

				RequestAPI.acceptOffer params
				.then (data)=>
					_.each @offers.all, (offer)=>
						if offer.id is offerId
							offer.deliveryDate = data.deliveryDate
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

			checkStatus : (status)->
				if (status == 'open')
					true
				else
					false

			onImageClick : (productID, e)->
				e.stopPropagation()
				App.navigate('single-product', {productID: productID})

		onDeviceBack = ->
				$ionicLoading.hide()
				App.goBack -1	

		inAppNotificationEvent = $rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_offer'
				if _.size($scope.view.offers.all) is 0 then $scope.view.offers.get()
				else $scope.view.offers.getSilently()

			if payload.type is 'request_delivery_changed'
				$scope.view.request.status = payload.requestStatus
		
		$scope.$on '$destroy', ->
			inAppNotificationEvent()
			$interval.cancel $scope.view.interval

		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
]


.controller 'EachOfferTimeCtrl', ['$scope', '$interval', 'TimeString', 'DeliveryTime'
	, ($scope, $interval, TimeString, DeliveryTime)->

		$scope.offer.deliveryTimeStr = DeliveryTime.humanize $scope.offer.deliveryTime
		
		#Offer time & left delivery time
		setTime = ->
			$scope.offer.timeStr = TimeString.get $scope.offer.createdAt
			$scope.offer.deliveryTimeLeftStr = DeliveryTime.left $scope.offer.deliveryDate

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

