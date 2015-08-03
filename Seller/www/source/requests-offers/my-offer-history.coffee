angular.module 'LocalHyper.requestsOffers'


.controller 'MyOfferHistoryCtrl', ['$scope', 'App', 'OffersAPI', '$ionicModal', '$timeout', '$rootScope'
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

			init : ->
				@offerDetails.loadModal()

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			reFetch : ->
				@display = 'loader'
				@requests = []
				@page = 0
				@canLoadMore = true
				@refresh = false
				@showOfferHistory()

			showOfferHistory : ()->
				params = page: @page, displayLimit: 3

				OffersAPI.getSellerOffers params
				.then (data)=>
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
					if offerDataSize < displayLimit then @canLoadMore = false
					else @onScrollComplete()
					if @refresh then @requests = offerData
					else @requests = @requests.concat(offerData)
				else
					@canLoadMore = false

			onError: (type)->
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			onTapToRetry : ->
				@display = 'loader'
				@page = 0
				@canLoadMore = true

			onPullToRefresh : ->
				@refresh = true
				@page = 0
				@canLoadMore = true
				@showOfferHistory()

			onInfiniteScroll : ->
				@refresh = false
				@showOfferHistory()

		
		$scope.$on 'modal.hidden', ->
			$timeout ->
				$scope.view.offerDetails.showExpiry = false
			, 1000

		$rootScope.$on 'make:offer:success', ->
			App.scrollTop()
			$scope.view.reFetch()
]


.directive 'ajCountDown', ['$timeout', '$parse', ($timeout, $parse)->
	
	restrict: 'A'
	link: (scope, el, attrs)->

		$timeout ->
			createdAt = $parse(attrs.createdAt)(scope)
			total = moment(moment(createdAt.iso)).add 24, 'hours'
			totalStr = moment(total).format 'YYYY/MM/DD HH:mm:ss'
			$(el).countdown totalStr, (event)->
				$(el).html event.strftime('%-H:%-M:%-S')
]


