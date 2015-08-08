angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', 'RequestsAPI', '$rootScope'
	, '$ionicModal', 'User', 'CToast', 'OffersAPI', 'CSpinner', '$ionicScrollDelegate'
	, '$q', '$timeout', '$ionicLoading', '$ionicPlatform', 'CDialog'
	, ($scope, App, RequestsAPI, $rootScope, $ionicModal, User, CToast, OffersAPI
	, CSpinner, $ionicScrollDelegate, $q, $timeout, $ionicLoading, $ionicPlatform, CDialog)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			requests: []
			pendingRequestIds: []

			sortBy: '-createdAt.iso'
			sortName: 'Most Recent'

			filter:
				modal: null
				attribute: 'category'
				allAttributes: []
				attrValues: {}
				originalValues: {}
				defaultRadius: User.getCurrent().get 'deliveryRadius'
				selectedFilters: 
					categories: []
					brands: []
					mrp: []
					radius: @defaultRadius

				plus : ->
					@attrValues['radius']++ if @attrValues['radius'] < 100
				minus : ->
					@attrValues['radius']-- if @attrValues['radius'] > 1

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/requests-offers/new-request-filter.html', 
						scope: $scope,
						animation: 'slide-in-up'
						hardwareBackButtonClose: false
					.then (modal)=>
						@modal = modal

				getPriceRange : (priceRange)->
					prices = []
					min = priceRange[0]
					max = priceRange[1]
					if max <= 1000 then increment = 100
					else if max <= 5000 then increment = 1000
					else if max <= 25000 then increment = 5000
					else if max <= 50000 then increment = 10000
					else if max <= 75000 then increment = 15000
					else if max <= 100000 then increment = 20000
					else increment = 25000
					priceRange = _.range min, max, increment
					_.each priceRange, (start, index)->
						end = priceRange[index+1]
						end = max if _.isUndefined(end)
						prices.push 
							start: start
							end: end
							name: "Rs #{start} - Rs #{end}"
					prices

				setAttrValues: ->
					@allAttributes.push value: 'category', name: 'Category', selected: 0
					@allAttributes.push value: 'brand', name: 'Brand', selected: 0
					@allAttributes.push value: 'mrp', name: 'MRP', selected: 0
					@allAttributes.push value: 'distance', name: 'Distance', selected: 0

					requests = $scope.view.requests
					@attrValues['category'] = _.uniq _.pluck(requests, 'category'), (val)-> val.id
					@attrValues['brand']    = _.uniq _.pluck(requests, 'brand'), (val)-> val.id
					allMRPs = _.pluck _.pluck(requests, 'product'), 'mrp'
					priceRange = [_.min(allMRPs), _.max(allMRPs)]
					@attrValues['mrp'] = @getPriceRange [_.min(allMRPs), _.max(allMRPs)]
					@attrValues['radius'] = @defaultRadius

					# De-select all attr values
					_.each @attrValues, (values)->
						_.each values, (val)-> val.selected = false

				showAttrCount : ->
					_.each @attrValues, (values, index)=>
						if _.isObject values
							count = 0
							_.each values, (val)-> count++ if val.selected
							attrIndex = _.findIndex @allAttributes, (attrs)-> attrs.value is index
							@allAttributes[attrIndex].selected = count

				onRadiusChange : ->
					@allAttributes[3].selected = 1

				clearFilters : ->
					_.each @attrValues, (values)->
						_.each values, (val)-> val.selected = false

					_.each @allAttributes, (attrs)-> attrs.selected = 0

					@selectedFilters = 
						categories: []
						brands:[]
						mrp:[]
						radius: @defaultRadius

				resetFilters : ->
					@attribute = 'category'
					@clearFilters()

				noChangeInSelection : ->
					_.isEqual _.sortBy(@originalValues), _.sortBy(@attrValues)

				openModal : ->
					@originalValues = JSON.parse JSON.stringify(@attrValues)
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
									@attrValues = @originalValues
									@showAttrCount()
									@modal.hide()
								when 2
									@onApply()

				onApply : ->
					_.each @attrValues, (_values, attribute)=>
						switch attribute
							when 'price'
								start = []
								end = []
								_.each _values, (price)=>
									if price.selected
										start.push price.start
										end.push price.end
								
								if _.isEmpty(start) then @selectedFilters.price = []
								else @selectedFilters.price = [_.min(start), _.max(end)]

							when 'brand'
								selected = []
								_.each _values, (brand)=>
									selected.push(brand.id) if brand.selected
								@selectedFilters.brands = selected
					
					@modal.hide()
					$scope.view.reFetch()

			
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
					defer = $q.defer()
					if _.isNull @modal
						$ionicModal.fromTemplateUrl 'views/requests-offers/new-request-details.html', 
							scope: $scope,
							animation: 'slide-in-up'
							hardwareBackButtonClose: true
						.then (modal)=>
							defer.resolve @modal = modal
					else defer.resolve()
					defer.promise

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
					console.log request
					@data = request
					@resetModal()
					@modal.show()
					@markNotificationAsSeen request

				markNotificationAsSeen : (request)->
					if !request.notification.hasSeen
						requests = $scope.view.requests
						index = _.findIndex requests, (val)-> val.id is request.id
						RequestsAPI.updateNotificationStatus request.id
						.then (data)=>
							App.notification.decrement()
							requests[index].notification.hasSeen = true

				onNotificationClick : (requestId)->
					requests = $scope.view.requests
					index = _.findIndex requests, (val)-> val.id is requestId
					if index isnt -1 
						@show requests[index]
					else
						#When request not present in list
						@loadModal().then =>
							$scope.view.pendingRequestIds.push requestId
							@display = 'loader'
							@modal.show()
							RequestsAPI.getSingleRequest requestId
							.then (request)=>
								if request.status is 'cancelled'
									CSpinner.show '', 'Sorry, this request has been cancelled'
									$timeout =>
										@modal.hide()
										CSpinner.hide()
									, 2000
								else
									@display = 'noError'
									@data = request
							, (type)=>
								@display = 'error'
								@errorType = type

				makeOffer : ->
					requestId = @data.id
					priceValue = ''
					switch @price
						when 'localPrice'
							priceValue = @data.platformPrice
						when 'onlinePrice'
							priceValue = @data.onlinePrice
						when 'yourPrice'
							priceValue = @offerPrice

					params = 
						"sellerId": User.getId()
						"requestId": requestId
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
							@removeRequestCard requestId
							@modal.hide()
							CToast.showLongBottom 'Your offer has been made. For more details, please check your offer history.'
							$rootScope.$broadcast 'make:offer:success'
						, (type)=>
							CToast.show 'Failed to make offer, please try again'
						.finally ->
							CSpinner.hide()

				removeRequestCard : (requestId)->
					spliceIndex = _.findIndex $scope.view.requests, (request)->
						request.id is requestId
					$scope.view.requests.splice(spliceIndex, 1) if spliceIndex isnt -1



			init : ->
				@getRequests()
				@filter.loadModal()
				@requestDetails.loadModal()

			autoFetch : ->
				@page = 0
				@requests = []
				@display = 'loader'
				@errorType = ''
				@getRequests()

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
				if _.isEmpty @filter.attrValues['category']
					@filter.setAttrValues()
				App.notification.newRequests = _.size @requests
				@markPendingNotificationsAsSeen()
			
			onError : (type)->
				@display = 'error'
				@errorType = type

			onPullToRefresh : ->
				@display = 'noError'
				$rootScope.$broadcast 'get:unseen:notifications'
				@getRequests()

			onTapToRetry : ->
				@display = 'loader'
				$rootScope.$broadcast 'get:unseen:notifications'
				@getRequests()

			markPendingNotificationsAsSeen : ->
				_.each @pendingRequestIds, (requestId)=>
					RequestsAPI.updateNotificationStatus requestId
					.then (data)=>
						index = _.findIndex @requests, (val)-> val.id is requestId
						if index isnt -1
							App.notification.decrement()
							@requests[index].notification.hasSeen = true

				@pendingRequestIds = []

			showSortOptions : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/requests-offers/new-request-sort.html'
					hideOnStateChange: true

			simulateFetch : ->
				App.scrollTop()
				@display = 'loader'
				$timeout =>
					@display = 'noError'
					App.resize()
				, 500

			onSort : (sortBy, sortName)->
				$ionicLoading.hide()

				switch sortBy
					when '-createdAt.iso'
						if @sortBy isnt '-createdAt.iso'
							@sortBy = '-createdAt.iso'
							@sortName = sortName
							@simulateFetch()
					when '-product.mrp'
						if @sortBy isnt '-product.mrp'
							@sortBy = '-product.mrp'
							@sortName = sortName
							@simulateFetch()
					when 'product.mrp'
						if @sortBy isnt 'product.mrp'
							@sortBy = 'product.mrp'
							@sortName = sortName
							@simulateFetch()
					when '-radius'
						if @sortBy isnt '-radius'
							@sortBy = '-radius'
							@sortName = sortName
							@simulateFetch()
					when 'radius'
						if @sortBy isnt 'radius'
							@sortBy = 'radius'
							@sortName = sortName
							@simulateFetch()
					when '-offerCount'
						if @sortBy isnt '-offerCount'
							@sortBy = '-offerCount'
							@sortName = sortName
							@simulateFetch()
					when 'offerCount'
						if @sortBy isnt 'offerCount'
							@sortBy = 'offerCount'
							@sortName = sortName
							@simulateFetch()


		
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
		
		$rootScope.$on 'in:app:notification', (e, obj)->
			payload = obj.payload
			switch payload.type
				when 'new_request'
					$scope.view.getRequests()
				when 'cancelled_request'
					$rootScope.$broadcast 'get:unseen:notifications'
					$scope.view.requestDetails.removeRequestCard payload.id
				when 'accepted_offer'
					$rootScope.$broadcast 'get:accepted:offer:count'
		
		$rootScope.$on 'push:notification:click', (e, obj)->
			payload = obj.payload
			switch payload.type
				when 'new_request'
					App.navigate 'new-requests'
					$scope.view.requestDetails.onNotificationClick payload.id
				when 'cancelled_request'
					RequestsAPI.cancelledRequestId 'set', payload.id
					App.navigate 'my-offer-history'
				when 'accepted_offer'
					OffersAPI.acceptedOfferId 'set', payload.id
					App.navigate 'successful-offers'
		
		$scope.$on '$ionicView.afterEnter', ->
			App.hideSplashScreen()

		$rootScope.$on 'category:chain:changed', ->
			# App.scrollTop()
			$scope.view.autoFetch()
]


.controller 'EachRequestTimeCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->

	#Request time
	setTime = ->
		$scope.request.timeStr = TimeString.get $scope.request.createdAt

	setTime()
	interval = $interval setTime, 60000
	$scope.$on '$destroy', ->
		$interval.cancel interval
]

