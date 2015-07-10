angular.module 'LocalHyper.categories'


.controller 'CategoryChainsCtrl', ['$scope', 'App', 'CategoriesAPI'
	, ($scope, App, CategoriesAPI)->

		$scope.view = 

			categoryChains : CategoriesAPI.categoryChains('get')

			init : ->
				console.log CategoriesAPI.categoryChains('get')

			getBrands : (brands)->
				brandNames = _.pluck brands, 'name'
				brandNames.join ', '

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