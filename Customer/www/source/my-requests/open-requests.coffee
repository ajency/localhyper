angular.module 'LocalHyper.myRequests'

.controller 'OpenRequestCtrl', ['$scope', 'App', 'RequestAPI'
	, ($scope, App, RequestAPI)->

		$scope.view = 
			display: 'loader'
			errorType: ''
			openRequests: []
			page: 0
			canLoadMore: true

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			incrementPage : ->
				$scope.$broadcast 'scroll.refreshComplete'
				@page = @page + 1
							
			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onPullToRefresh : ->
				@openRequests = []
				@page = 0
				@getMyOffers()

			onTapToRetry : ->
				@canLoadMore = true
				@display = 'error'
				@page = 0
				
			getMyOffers : ()->
				RequestAPI.get
					page: @page
					openStatus: true
					displayLimit: 5
				.then (data)=>
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@incrementPage()
					@onScrollComplete()
					
			onSuccess : (data)->
				@display = 'noError'
				console.log('open request')
				console.log(data)
				openRequest = data
				if openRequest.length > 0
					@canLoadMore = true
					@openRequests = @openRequests.concat(openRequest)	
				else
					@canLoadMore = false


			onError: (type)->
				@canLoadMore = false
				@display = 'error'
				@errorType = type

			init : ->
				# @getMyOffers()	

			onInfiniteScroll : ->
				@getMyOffers()


		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			viewData.enableBack = true
]


