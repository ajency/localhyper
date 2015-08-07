angular.module 'LocalHyper.creditHistory', []


.controller 'creditHistoryCtrl', ['$scope', 'App', 'CategoriesAPI', 'Storage', 'RequestsAPI', 'DeliveryTime'
	, ($scope, App, CategoriesAPI, Storage, RequestsAPI, DeliveryTime)->

		# $scope.view = 
		# 	display: 'loader'
		# 	errorType: ''
		# 	requests: []
		# 	page: 0
		# 	canLoadMore: true
		# 	refresh: false

		# 	onScrollComplete : ->
		# 		$scope.$broadcast 'scroll.infiniteScrollComplete'

		# 	onInfiniteScroll : ->
		# 		@refresh = false
		# 		@showOfferHistory()

		# 	onPullToRefresh : ->
		# 		@refresh = true
		# 		@page = 0
		# 		@canLoadMore = true
		# 		@showOfferHistory()

		# 	onSuccess : (data)->
		# 		console.log(data)
		# 		@display = 'noError'
		# 		offerDataSize = _.size(offerData)
		# 		if offerDataSize > 0
		# 			if offerDataSize < displayLimit
		# 				@canLoadMore = false
		# 			else
		# 				@canLoadMore = true
		# 				@onScrollComplete() 

		# 			if @refresh then @requests = offerData
		# 			else @requests = @requests.concat offerData
		# 		else
		# 			@canLoadMore = false

		# 	onError: (type)->
		# 		@display = 'error'
		# 		@errorType = type
		# 		@canLoadMore = false


		# 	showOfferHistory : ->
				
		# 		# params = 
		# 		# 	page: @page
		# 		# 	acceptedOffers: false
		# 		# 	displayLimit: 3
		# 		# 	sortBy: @sortBy
		# 		# 	descending: @descending
		# 		# 	selectedFilters: @filter.selected

		# 		# OffersAPI.getSellerOffers params
		# 		# .then (data)=>
		# 		# 	console.log data
		# 		# 	@onSuccess data, params.displayLimit
		# 		# , (error)=>
		# 		# 	@onError error
		# 		# .finally =>
		# 		# 	App.resize()
		# 		# 	@page = @page + 1
		# 		# 	$scope.$broadcast 'scroll.refreshComplete'

		# 		RequestsAPI.getAll()
		# 		.then (data)=>
		# 			console.log data
		# 			@onSuccess data
		# 		, (error)=>
		# 			@onError error
		# 		.finally ->
		# 			$scope.$broadcast 'scroll.refreshComplete'
				

		# $scope.$on '$ionicView.beforeEnter', (event, viewData)->
		# 	if !viewData.enableBack
		# 		viewData.enableBack = true			

]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'credit-history',
			url: '/credit-history'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					templateUrl: 'views/credit-history/credit-history.html'
					controller: 'creditHistoryCtrl'

]