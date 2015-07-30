angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', '$rootScope'
	, '$ionicModal', 'Push', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate'
	, ($scope, App, RequestsAPI, $rootScope, $ionicModal, Push, User, CToast, OffersAPI
	, CSpinner, $ionicScrollDelegate)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			requestIds: []

			requestDetails:
				modal: null
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

				showModal : (requestId)->
					@requestId = requestId
					@modal.show()
					@get()

				get : ->
					@display = 'loader'
					RequestsAPI.getById @requestId
					.then (request)=>
						console.log request
						@display = 'noError'
						@data = request
						$scope.view.markNotificationAsSeen request.objectId
					, (type)=>
						@display = 'error'
						@errorType = type

				makeOffer : ->
					user = User.getCurrent()
					priceValue = ''
					switch @price
						when 'localPrice'
							priceValue = '9000'
						when 'onlinePrice'
							priceValue = '9000'
						when 'yourPrice'
							priceValue = @offerPrice

					params = 
						"sellerId": user.id
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
							@modal.hide()
							CToast.show 'Your offer has been made'
							$rootScope.$broadcast 'offer:done:succ'
						, (type)=>
							CToast.show 'Failed to make offer, please try again'
						.finally ->
							CSpinner.hide()


			init : ->
				Push.register()
				@getRequests()
				@loadRequestDetails()

			loadRequestDetails : ->
				$ionicModal.fromTemplateUrl 'views/requests-offers/request-details.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: true
				.then (modal)=>
					@requestDetails.modal = modal

			getRequests : ->
				RequestsAPI.getNotifications()
				.then (requestIds)=>
					@requestIds = requestIds
					notifications = _.size requestIds
					if notifications > 0
						App.notification.badge = true
						App.notification.count = notifications
					RequestsAPI.getAll()
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error

			onSuccess : (data)->
				@display = 'noError'
				@requests = data.requests
			
			onError: (type)->
				@display = 'error'
				@errorType = type

			isNew : (requestId)->
				_.contains @requestIds, requestId

			onTapToRetry : ->
				@display = 'loader'
				@getRequests()

			showRequestDetails : (request)->
				@requestDetails.data = request
				@requestDetails.resetModal()
				@requestDetails.modal.show()
				@markNotificationAsSeen request.id

			markNotificationAsSeen : (requestId)->
				index = _.findIndex @requests, (val)-> val.id is requestId
				if index isnt -1
					newRequest = @requests[index].new 
					if newRequest
						RequestsAPI.updateStatus requestId
						.then (data)=>
							App.notification.decrement()
							@requests[index].new = false


		$rootScope.$on 'on:new:request', ->
			$scope.view.getRequests()

		$rootScope.$on 'on:notification:click', (e, obj)->
			$scope.view.requestDetails.showModal obj.payload.id
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()
]

