angular.module 'LocalHyper.creditHistory', []


.controller 'creditHistoryCtrl', ['$scope', 'App', 'CreditHistoryAPI', 'User'
	, ($scope, App, CreditHistoryAPI, User)->
		
		$scope.view = 
			display: 'loader'
			errorType: ''
			page: 0
			canLoadMore: true
			refresh: false
			creditHistoryData : []
			gotAllRecords: false

			init : ->
				@getCreditDetails()

			getCreditDetails : ->
				User.update()
				.then (user)=>
					@setCreditDetails user
				, (error)=>
					@setCreditDetails User.getCurrent()

			setCreditDetails : (user)->
				$scope.$apply =>
					totalCredit = user.get 'addedCredit'
					usedCredit  = user.get 'subtractedCredit'
					@creditAvailable = parseInt(totalCredit) - parseInt(usedCredit)
					@creditUsed = usedCredit

			onInfiniteScroll : ->
				@refresh = false
				@getCreditHistory()

			onPullToRefresh : ->
				@gotAllRecords  = false
				@refresh = true
				@page = 0
				@canLoadMore = true
				@getCreditDetails()
				@getCreditHistory()

			getCreditHistory : ->
				params = page: @page, displayLimit: 5
				
				CreditHistoryAPI.getAll params
				.then (data)=>
					@onSuccess data, params.displayLimit
				, (error)=>
					@onError error
				.finally =>
					@page = @page + 1
					$scope.$broadcast 'scroll.refreshComplete'
					App.resize()

			onSuccess : (data, displayLimit)->
				@display = 'noError'
				totalRecords = _.size data
				if totalRecords > 0
					if totalRecords < displayLimit
						@canLoadMore = false
					else
						@canLoadMore = true
						$scope.$broadcast 'scroll.infiniteScrollComplete'

					if @refresh then @creditHistoryData = data
					else @creditHistoryData = @creditHistoryData.concat data
				else
					@canLoadMore = false

				@gotAllRecords = true if !@canLoadMore

			onError: (type)->
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			onTapToRetry : ->
				@creditHistoryData = []
				@getCreditDetails()
				@display = 'loader'
				@page = 0
				@canLoadMore = true

			getTransactionDate : (createdAt)->
				moment(createdAt.iso).format 'DD/MM/YYYY'

		
		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
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
