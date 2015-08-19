angular.module 'LocalHyper.categories'


.controller 'CategoryChainsCtrl', ['$scope', 'App', 'CategoriesAPI', 'Storage', 'CategoryChains'
	, ($scope, App, CategoriesAPI, Storage, CategoryChains)->

		$scope.view = 
			showDelete: false
			categoryChains : []

			init : ->
				@setCategoryChains()

			setCategoryChains : ->
				if !_.isNull CategoryChains
					@categoryChains = CategoryChains
					CategoriesAPI.categoryChains 'set', CategoryChains

			getBrands : (brands)->
				brandNames = _.pluck brands, 'name'
				brandNames.join ', '

			removeItemFromChains : (subCategoryId)->
				@categoryChains = CategoriesAPI.categoryChains 'get'
				spliceIndex = _.findIndex @categoryChains, (chains)->
					chains.subCategory.id is subCategoryId
				@categoryChains.splice spliceIndex, 1
				
				CategoriesAPI.categoryChains 'set', @categoryChains
				Storage.categoryChains 'set', @categoryChains
				.then ->
					App.resize()

			onChainClick : (chains)->
				CategoriesAPI.subCategories 'set', chains.category.children
				App.navigate 'brands', categoryID: chains.subCategory.id
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'category-chains',
			url: '/category-chains'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					templateUrl: 'views/categories/category-chains.html'
					controller: 'CategoryChainsCtrl'
					resolve: 
						CategoryChains : ($q, Storage)->
							defer = $q.defer()
							Storage.categoryChains 'get'
							.then (chains)->
								defer.resolve chains
							defer.promise
]

