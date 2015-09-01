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

			resetSort : ->
				@sortBy = '-createdAt.iso'
				@sortName = 'Most Recent'

			filter:
				modal: null

				reset : ->
					@attribute = 'category'
					@excerpt = ''
					@allAttributes = []
					@attrValues = {}
					@originalValues = {}
					@other = {}
					@defaultRadius = User.getCurrent().get('deliveryRadius')
					@selectedCategories = 'default'
					@selectedBrands = 'default'
					@selectedMrp = 'default'
					@selectedRadius = 'default'

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

				getPriceRange : ->
					prices = [
						{start: -1,    end: 1000,  name: "Rs 1000 & Below"}
						{start: 1000,  end: 5000,  name: "Rs 1000 - Rs 5000"}
						{start: 5000,  end: 10000, name: "Rs 5000 - Rs 10000"}
						{start: 10000, end: 15000, name: "Rs 10000 - Rs 15000"}
						{start: 15000, end: 20000, name: "Rs 15000 - Rs 20000"}
						{start: 20000, end: 25000, name: "Rs 20000 - Rs 25000"}
						{start: 25000, end: 30000, name: "Rs 25000 - Rs 30000"}
						{start: 30000, end: 35000, name: "Rs 30000 - Rs 35000"}
						{start: 35000, end: 40000, name: "Rs 35000 - Rs 40000"}
						{start: 40000, end: 45000, name: "Rs 40000 - Rs 45000"}
						{start: 45000, end: 50000, name: "Rs 45000 - Rs 50000"}
						{start: 50000, end: -1,    name: "Rs 50000 & Above"}]

				setAttrValues: ->
					@attrValues['category'] = @other.sellerCategories
					@attrValues['brand']    = @other.sellerBrands
					@attrValues['mrp']      = @getPriceRange()
					@attrValues['radius']   = @defaultRadius

					@allAttributes.push value: 'category', name: 'Category', selected: 0
					@allAttributes.push value: 'brand', name: 'Brand', selected: 0
					@allAttributes.push value: 'mrp', name: 'MRP', selected: 0
					@allAttributes.push value: 'radius', name: 'Distance'

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

				clearFilters : ->
					_.each @attrValues, (values)->
						_.each values, (val)-> val.selected = false
					@attrValues['radius']   = @defaultRadius
					
					_.each @allAttributes, (attrs)-> attrs.selected = 0

					@selectedCategories = 'default'
					@selectedBrands = 'default'
					@selectedMrp = 'default'
					@selectedRadius = 'default'

				noChangeInSelection : ->
					@attrValues['radius'] = parseInt @attrValues['radius']
					@originalValues['radius'] = parseInt @originalValues['radius']
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
							when 'category'
								selected = []
								_.each _values, (category)->
									selected.push(category.id) if category.selected
								@selectedCategories = if _.isEmpty(selected) then 'default' else selected

							when 'brand'
								selected = []
								_.each _values, (brand)=>
									selected.push(brand.id) if brand.selected
								@selectedBrands = if _.isEmpty(selected) then 'default' else selected

							when 'mrp'
								start = []
								end = []
								_.each _values, (mrp)=>
									if mrp.selected
										start.push mrp.start
										end.push mrp.end

								@selectedMrp = if _.isEmpty(start) then 'default' else [_.min(start), _.max(end)]

							when 'radius'
								radius = parseInt _values
								@selectedRadius = if radius is @defaultRadius then 'default' else radius
					
					@setExcerpt()
					@modal.hide()
					$scope.view.reFetch()

				setExcerpt : ->
					filterNames = []
					_.each @allAttributes, (attr, index)=>
						if attr.name is 'Distance'
							if parseInt(@attrValues['radius']) isnt parseInt(@defaultRadius)
								filterNames.push(attr.name)
						else filterNames.push(attr.name) if attr.selected > 0
					@excerpt = filterNames.join ', '

			
			
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
					unit: 'day'
					unitText: 'Day'

					setDuration : ->
						if !_.isNull @value
							switch @unit
								when 'hr'
									@unitText = if @value is 1 then 'Hour' else 'Hours'
								when 'day'
									@unitText = if @value is 1 then 'Day' else 'Days'

					plus : ->
						@value++
						@setDuration()
						
					minus : ->
						@value-- if @value > 1
						@setDuration()

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
							hardwareBackButtonClose: false
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
					@deliveryTime.unit = 'day'
					@deliveryTime.unitText = 'Day'
					@reply.button = true
					@reply.text = ''
					$ionicScrollDelegate
						.$getByHandle 'request-details'
						.scrollTop()

				show : (request)->
					@data = request
					@resetModal()
					@modal.show()
					@makeOfferBtn = false
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

					onError = (msg)=>
						CSpinner.show '', msg
						$timeout =>
							@modal.hide()
							CSpinner.hide()
						, 2000

					if index isnt -1 
						@show requests[index]
					else
						#When request not present in list
						@loadModal().then =>
							$scope.view.pendingRequestIds.push requestId
							@display = 'loader'
							@makeOfferBtn = false
							@modal.show()
							RequestsAPI.getSingleRequest requestId
							.then (request)=>
								if request.status is 'cancelled'
									onError 'Sorry, this request has been cancelled'
								else if _.isEmpty requests
									@display = 'noError'
									@data = request
								else
									reqIndex = _.findIndex requests, (val)-> val.id is request.id
									if reqIndex is -1
										onError 'You have already made an offer'
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
					else if _.isNull(@deliveryTime.value) || @deliveryTime.value == 0
						CToast.show 'Please enter delivery time'
					else
						CSpinner.show '', 'Please wait...'
						OffersAPI.makeOffer params
						.then (data)=>
							@removeRequestCard requestId
							@makeOfferBtn = true
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
					$scope.view.setRequestsCount()

			init : ->
				@filter.reset()
				@filter.loadModal()
				@requestDetails.loadModal()
				@getRequests()

			reFetch : ->
				App.scrollTop()
				@requests = []
				@display = 'loader'
				@getRequests()

			setRequestsCount : ->
				App.notification.newRequests = _.size @requests

			getRequests : ->
				options = 
					sellerRadius: @filter.selectedRadius
					categories: @filter.selectedCategories
					brands: @filter.selectedBrands
					productMrp: @filter.selectedMrp

				RequestsAPI.getAll options
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error
				.finally ->
					$scope.$broadcast 'scroll.refreshComplete'
					App.resize()

			onSuccess : (data)->
				@display = 'noError'
				@requests = data.requests
				@filter.other['sellerBrands']     = data.sellerBrands
				@filter.other['sellerCategories'] = data.sellerCategories
				if _.isEmpty @filter.attrValues
					@filter.setAttrValues()
				@setRequestsCount()
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
			detailsModal = $scope.view.requestDetails.modal
			if $('.loading-container').hasClass 'visible'
				$ionicLoading.hide()
			else if filter.modal.isShown()
				filter.closeModal()
			else if detailsModal.isShown()
				detailsModal.hide()
			else
				App.goBack -1

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack

		$rootScope.$on 'category:chain:updated', ->
			$scope.view.resetSort()
			$scope.view.filter.reset()
			$scope.view.reFetch()
		
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
]


.controller 'EachRequestTimeCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->

	getLowestPrice = ->
		platformPrice = $scope.request.platformPrice
		mrp = $scope.request.product.mrp
		onlinePrice = $scope.request.onlinePrice
		priceArray = []
		priceArray.push(platformPrice) if platformPrice isnt ''
		priceArray.push(mrp) if mrp isnt '' 
		priceArray.push(onlinePrice) if onlinePrice isnt '' 
		_.min priceArray

	$scope.request.lowestPrice = getLowestPrice()

	#Request time
	setTime = ->
		$scope.request.timeStr = TimeString.get $scope.request.createdAt

	setTime()
	interval = $interval setTime, 60000
	$scope.$on '$destroy', ->
		$interval.cancel interval
]

