angular.module 'LocalHyper.myRequests'

.controller 'OpenRequestCtrl', ['$scope', 'App', 'RequestAPI', '$ionicLoading'
	, ($scope, App, RequestAPI, $ionicLoading)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			openRequests: []
			page: 0
			canLoadMore: true
			refresh: false
			getOpenProducts: false
			selectedFilters : []

			onClick : (request)->
				RequestAPI.requestDetails 'set', request
				App.navigate 'request-details'

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			incrementPage : ->
				$scope.$broadcast 'scroll.refreshComplete'
				@page = @page + 1
							
			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onPullToRefresh : ->
				@getOpenProducts = false
				@page = 0
				@refresh = true
				@getMyOffers()
				@canLoadMore = true

			onTapToRetry : ->
				@canLoadMore = true
				@display = 'error'
				@page = 0
				
			getMyOffers : ()->
				RequestAPI.get
					page: @page
					displayLimit : 3
					requestType : 'nonexpired'
					selectedFilters : @selectedFilters
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@incrementPage()
					
			onSuccess : (data)->
				@display = 'noError'
				openRequest = data
				if openRequest.length > 0
					if _.size(openRequest) < 3 then @canLoadMore = false
					else @onScrollComplete()
					if @refresh then @openRequests = openRequest
					else @openRequests = @openRequests.concat(openRequest)
				else
					@canLoadMore = false
					
				if !@canLoadMore
				    @getOpenProducts = true

			onError: (type)->
				@canLoadMore = false
				@display = 'error'
				@errorType = type

			init : ->
				# @getMyOffers()	

			onInfiniteScroll : ->
				@refresh = false
				@getMyOffers()

			Filter : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/my-requests/filter.html'
					hideOnStateChange: true
					
			onFilter:(status)->
				@canLoadMore = true
				$ionicLoading.hide()
				if status != 'null'
					@selectedFilters = [status]
				else 
					@selectedFilters = []
				@refresh = true
				@page = 0
				@openRequests = []
				
				@getOpenProducts = false
				@onScrollComplete()	


		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			viewData.enableBack = true
]


