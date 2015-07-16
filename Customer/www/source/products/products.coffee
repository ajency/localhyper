angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal'
	, '$timeout', 'App', 'CToast', 'UIMsg', '$ionicLoading', '$ionicPlatform'
	, ($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg
	, $ionicLoading, $ionicPlatform)->

		$scope.view =
			title: Product.subCategoryTitle
			products: []
			page: 0
			footer: false
			canLoadMore: true
			refresh: false
			sortBy: 'popularity'
			ascending: true

			reset : ->
				@products = []
				@page = 0
				@footer = false
				@canLoadMore = true
				@refresh = false
				@sortBy = 'popularity'
				@ascending = true
				@onScrollComplete()

			showSortOptions : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/products/sort.html'
					hideOnStateChange: true

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			onRefreshComplete : ->
				$scope.$broadcast 'scroll.refreshComplete'
			
			incrementPage : ->
				@page = @page + 1
			
			onPullToRefresh : ->
				if App.isOnline()
					@canLoadMore = true
					@page = 0
					@refresh = true
					@getProducts()
				else
					@onRefreshComplete()
					CToast.show UIMsg.noInternet

			onInfiniteScroll : ->
				@refresh = false
				@getProducts()

			getProducts : ->
				ProductsAPI.getAll
					categoryID: $stateParams.categoryID
					page: @page
					sortBy: @sortBy
					ascending: @ascending
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@footer = true
					@incrementPage()
					@onRefreshComplete()

			onError : (error)->
				console.log error
				@canLoadMore = false
			
			onSuccess : (data)->
				_products = data.products
				if _.size(_products) > 0
					if _.size(_products) < 10 then @canLoadMore = false
					else @onScrollComplete()
					if @refresh then @products = _products
					else @products = @products.concat _products
				else
					@canLoadMore = false

			getPrimaryAttrs : (attrs)->
				if !_.isUndefined attrs
					attrs = attrs[0]
					value = s.humanize attrs.value
					unit = ''
					if _.has attrs.attribute, 'unit'
						unit = s.humanize attrs.attribute.unit
					"#{value} #{unit}"
				else ''

			onSort : (sortBy, ascending)->
				$ionicLoading.hide()

				reFetch = =>
					@page = 0
					@refresh = true
					@products = []
					@canLoadMore = true
					@onScrollComplete()

				switch sortBy
					when 'popularity'
						if @sortBy isnt 'popularity'
							@sortBy = 'popularity'
							@ascending = true
							reFetch()
					when 'mrp'
						if @sortBy isnt 'mrp'
							@sortBy = 'mrp'
							@ascending = ascending
							reFetch()
						else if @ascending isnt ascending
							@sortBy = 'mrp'
							@ascending = ascending
							reFetch()

		
		onDeviceBack = ->
			if $('.loading-container').hasClass 'visible'
				$ionicLoading.hide()
			else
				App.goBack -1

		$scope.$on '$ionicView.beforeEnter', ->
			if _.contains ['categories', 'sub-categories'], App.previousState
				$scope.view.reset()

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'products',
			url: '/products:categoryID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/products.html'
					controller: 'ProductsCtrl'
					resolve:
						Product: ($stateParams, CategoriesAPI)->
							subCategories = CategoriesAPI.subCategories 'get'
							childCategory = _.filter subCategories, (category)->
								category.id is $stateParams.categoryID
							
							subCategoryTitle: childCategory[0].name 
]

