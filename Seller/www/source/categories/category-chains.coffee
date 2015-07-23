angular.module 'LocalHyper.categories'


.controller 'CategoryChainsCtrl', ['$scope', 'App', 'CategoriesAPI', 'Storage'
	, ($scope, App, CategoriesAPI, Storage)->

		$scope.view = 
			categoryChains : []

			setCategoryChains : ->
				Storage.categoryChains 'get'
				.then (chains) =>
					if !_.isNull chains
						@categoryChains = chains
						CategoriesAPI.categoryChains 'set', chains

			getBrands : (brands)->
				brandNames = _.pluck brands, 'name'
				brandNames.join ', '

			removeItemFromChains : (subCategoryId)->
				@setCategoryChains()
				spliceIndex = _.findIndex @categoryChains, (chains)->
					chains.subCategory.id is subCategoryId
				@categoryChains.splice spliceIndex, 1
				CategoriesAPI.categoryChains 'set', @categoryChains
				Storage.categoryChains 'set', @categoryChains
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

]