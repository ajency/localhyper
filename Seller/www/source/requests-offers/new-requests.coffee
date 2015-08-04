angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', '$rootScope'
	, '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate'
	, ($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI
	, CSpinner, $ionicScrollDelegate)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			pendingRequestIds: []

			requestDetails:
				modal: null
				data: {}
				display: 'noError'
				errorType: ''
				offerPrice: ''
				reply: button: true, text: ''
				
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

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/request-details.html', 
						scope: $scope,
						animation: 'slide-in-up'
						hardwareBackButtonClose: true
					.then (modal)=>
						@modal = modal

				resetModal : ->
					@display = 'noError'
					@price = null
					@offerPrice = ''
					@deliveryTime.display = false
					@deliveryTime.value = 1
					@deliveryTime.unit = 'hr'
					@deliveryTime.unitText = 'Hour'
					@reply.button = true
					@reply.text = ''
					$ionicScrollDelegate
						.$getByHandle 'request-details'
						.scrollTop()

				show : (request)->
					@data = request
					@resetModal()
					@modal.show()
					@markNotificationAsSeen request

				markNotificationAsSeen : (request)->
					if !request.notification.hasSeen
						requests = $scope.view.requests
						index = _.findIndex requests, (val)-> val.id is request.id
						RequestsAPI.updateStatus request.id
						.then (data)=>
							App.notification.decrement()
							requests[index].notification.hasSeen = true

				onNotificationClick : (requestId)->
					requests = $scope.view.requests
					index = _.findIndex requests, (val)-> val.id is requestId
					if index is -1 #When request not present in list
						$scope.view.pendingRequestIds.push requestId
						@display = 'loader'
						@modal.show()
						RequestsAPI.getSingleRequest requestId
						.then (request)=>
							@display = 'noError'
							@data = request
						, (type)=>
							@display = 'error'
							@errorType = type
					else
						@show requests[index]

				makeOffer : ->
					priceValue = ''
					switch @price
						when 'localPrice'
							priceValue = '9000'
						when 'onlinePrice'
							priceValue = '9000'
						when 'yourPrice'
							priceValue = @offerPrice

					params = 
						"sellerId": User.getId()
						"requestId": @data.id
						"priceValue": priceValue
						"deliveryTime":
							"value": @deliveryTime.value
							"unit": @deliveryTime.unit
						"comments": @reply.text
						"status": "open"

					if _.isNull(@price)
						CToast.show 'Please select price'
					else if _.isNull(priceValue) or priceValue is ''
						CToast.show 'Please enter your offer price'
					else
						CSpinner.show '', 'Please wait...'
						OffersAPI.makeOffer params
						.then (data)=>
							@removeRequestCard()
							@modal.hide()
							CToast.showLongBottom 'Your offer has been made. For more details, please check your offer history.'
							$rootScope.$broadcast 'make:offer:success'
						, (type)=>
							CToast.show 'Failed to make offer, please try again'
						.finally ->
							CSpinner.hide()

				removeRequestCard : ->
					requestId = @data.id
					spliceIndex = _.findIndex $scope.view.requests, (request)->
						request.id is requestId
					$scope.view.requests.splice(spliceIndex, 1) if spliceIndex isnt -1



			init : ->
				@getRequests()
				@requestDetails.loadModal()

			getRequests : ->
				RequestsAPI.getAll()
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error
				.finally ->
					$scope.$broadcast 'scroll.refreshComplete'

			onSuccess : (data)->
				@display = 'noError'
				@requests = data.requests
				@markPendingNotificationsAsSeen()
			
			onError : (type)->
				@display = 'error'
				@errorType = type

			onPullToRefresh : ->
				@display = 'noError'
				@getRequests()

			onTapToRetry : ->
				@display = 'loader'
				$rootScope.$broadcast 'get:unseen:notifications'
				@getRequests()

			markPendingNotificationsAsSeen : ->
				_.each @pendingRequestIds, (requestId)=>
					RequestsAPI.updateStatus requestId
					.then (data)=>
						index = _.findIndex @requests, (val)-> val.id is requestId
						App.notification.decrement()
						@requests[index].notification.hasSeen = true

				@pendingRequestIds = []


		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_request'
				$scope.view.getRequests()

		$rootScope.$on 'push:notification:click', (e, obj)->
			payload = obj.payload
			if payload.type is 'new_request'
				$scope.view.requestDetails.onNotificationClick payload.id
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]

