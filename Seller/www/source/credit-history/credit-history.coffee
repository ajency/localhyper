angular.module 'LocalHyper.creditHistory', []


.controller 'creditHistoryCtrl', ['$scope', 'App', 'creditHistoryAPI', 'User'
	, ($scope, App, creditHistoryAPI, User)->

		
		$scope.view = 
			display: 'loader'
			errorType: ''
			page: 0
			canLoadMore: true
			refresh: false
			availableCredit :''
			creditHistoryData : []
			getAllCreditHistory: false

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'

			onInfiniteScroll : ->
				@getTotalCredit()
				@refresh = false
				@creditHistory()

			onPullToRefresh : ->
				@getAllHistory  = false
				@refresh = true
				@page = 0
				@canLoadMore = true
				@creditHistory()


			getTotalCredit :->
				user = User.getCurrent()
				@availableCredit = parseInt(user._serverData.addedCredit) - parseInt(user._serverData.subtractedCredit)
				@creditUsed = user._serverData.subtractedCredit 


			onSuccess : (data, displayLimit)->
				@display = 'noError'
				creditHistory = _.size(data)
				if creditHistory > 0
					if creditHistory < displayLimit
						@canLoadMore = false
					else
						@canLoadMore = true
						@onScrollComplete() 

					if @refresh then @creditHistoryData = data
					else @creditHistoryData = @creditHistoryData.concat data
				else
					@canLoadMore = false

				@getAllHistory = true if !@canLoadMore	

			onError: (type)->
				@creditHistoryData = []
				@display = 'error'
				@errorType = type
				@canLoadMore = false

			creditHistory : ->
				params = 
					page: @page
					displayLimit: 5
					
				creditHistoryAPI.getCreditHistory params
				.then (data)=>
					@onSuccess data, params.displayLimit
				, (error)=>
					@onError error
				.finally =>
					App.resize()
					@page = @page + 1
					$scope.$broadcast 'scroll.refreshComplete'

			onTapToRetry : ->
				@display = 'loader'
				@page = 0
				@canLoadMore = true

		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true		

]

.controller 'EachDisplayDateCtrl', ['$scope', '$interval', 'TimeString', ($scope, $interval, TimeString)->
	iso       = $scope.request.createdAt.iso
	format    = 'DD/MM/YYYY HH:mm:ss'
	now       = moment().format format
	date = now.split(" ")
	$scope.request.timeStr = date[0]
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