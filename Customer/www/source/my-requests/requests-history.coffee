angular.module 'LocalHyper.myRequests'


.controller 'RequestsHistoryCtrl', ['$scope', 'App', 'RequestAPI', '$timeout', '$rootScope'
	, ($scope, App, RequestAPI, $timeout, $rootScope)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			expiredRequests: []
			page: 0
			canLoadMore: true
			refresh: false
			gotAllRequests: false
			shouldRefetch: false

			reFetch : ->
				@display = 'loader'
				@refresh = false
				@page = 0
				@expiredRequests = []
				@canLoadMore = true
				@gotAllRequests = false
				$timeout =>
					@onScrollComplete()

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onInfiniteScroll : ->
				@refresh = false
				@getExpiredRequests()

			onPullToRefresh : ->
				@gotAllRequests = false
				@page = 0
				@refresh = true
				@canLoadMore = false
				@getExpiredRequests()
				
			getExpiredRequests : ->
				options = 
					page: @page
					requestType : 'expired'
					selectedFilters : []
					displayLimit : 5

				RequestAPI.get options
				.then (data)=>
					@onSuccess data, options.displayLimit
				, (error)=>
					@onError error
				.finally =>
					@page = @page + 1
					$scope.$broadcast 'scroll.refreshComplete'
					App.resize()
					
			onSuccess : (data, displayLimit)->
				@display = 'noError'
				_requests = data
				requestsSize = _.size _requests
				if requestsSize > 0
					if requestsSize < displayLimit
						@canLoadMore = false
					else
						@canLoadMore = true
						@onScrollComplete()
					
					if @refresh then @expiredRequests = _requests
					else @expiredRequests = @expiredRequests.concat _requests
				else
					@canLoadMore = false

				@gotAllRequests = true if !@canLoadMore

			onError: (type)->
				@canLoadMore = false
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@canLoadMore = true
				@display = 'loader'
				@page = 0

			onRequestClick : (request)->
				RequestAPI.requestDetails 'set', request
				App.navigate 'request-details'

		
		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true

			if $scope.view.shouldRefetch
				$scope.view.shouldRefetch = false
				$scope.view.reFetch()

			cacheForStates = ['my-requests', 'request-details']
			if !_.contains cacheForStates, App.previousState
				$scope.view.reFetch()

		$rootScope.$on 're:fetch:expired:requests', ->
			$scope.view.shouldRefetch = true
]

