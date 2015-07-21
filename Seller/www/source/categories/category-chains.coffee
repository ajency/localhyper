angular.module 'LocalHyper.categories'


.controller 'CategoryChainsCtrl', ['$scope', 'App', 'CategoriesAPI'
	, ($scope, App, CategoriesAPI)->

		$scope.view = 
			categoryChains : null

			setCategoryChains : ->
				@categoryChains = CategoriesAPI.categoryChains('get')

			getBrands : (brands)->
				brandNames = _.pluck brands, 'name'
				brandNames.join ', '

			removeItemFromChains : (subCategoryId)->
				@setCategoryChains()
				_.each @categoryChains, (chains, index)=>
					if chains.subCategory.id is subCategoryId
						@categoryChains.splice index, 1

				CategoriesAPI.categoryChains 'set', @categoryChains
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