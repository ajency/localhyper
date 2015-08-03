angular.module 'LocalHyper.myRequests'


.controller 'RequestsHistoryCtrl', ['$scope', 'App', 'RequestAPI'
	, ($scope, App, RequestAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			openRequests: []
			page: 0
			canLoadMore: true
			refresh: false

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			incrementPage : ->
				$scope.$broadcast 'scroll.refreshComplete'
				@page = @page + 1
							
			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onPullToRefresh : ->
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
					requestType : 'expired'
					selectedFilters : []
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

			onError: (type)->
				@canLoadMore = false
				@display = 'error'
				@errorType = type

			init : ->
				# @getMyOffers()	

			onInfiniteScroll : ->
				@refresh = false
				@getMyOffers()

			onClick : (request)->
				RequestAPI.requestDetails 'set', request
				App.navigate 'request-details'

		
		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
]





