angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal', '$timeout'
	, ($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout)->

		$scope.view =
			title: Product.subCategoryTitle
			products: []
			page: 0
			canLoadMore: true
			refresh: false
			sortModal: null
			sortBy: 'popularity'
			ascending: true
			
			init: ->
				@loadSortModal()

			loadSortModal : ->
				$ionicModal.fromTemplateUrl 'views/products/sort.html', 
					scope: $scope,
					animation: 'slide-in-up'
				.then (modal)=>
					@sortModal = modal

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			onRefreshComplete : ->
				$scope.$broadcast 'scroll.refreshComplete'
			
			incrementPage : ->
				@page = @page + 1
			
			onPullToRefresh : ->
				@canLoadMore = true
				@page = 0
				@refresh = true
				@getProducts()

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

			onSort : (sortBy, ascending)->
				@sortModal.hide()

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

