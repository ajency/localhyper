angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI'
	, ($scope, User, App, CToast, Storage, CategoriesAPI)->

		user = User.getCurrent()
		
		console.log(user)

		$scope.view = 
			showDelete: false
			categoryChains : []

			setCategoryChains : ->
				Storage.categoryChains 'get'
				.then (chains) =>
					console.log(chains)
					if !_.isNull chains
						@categoryChains = chains
						CategoriesAPI.categoryChains 'set', chains

			getBrands : (brands)->
				brandNames = _.pluck brands, 'name'
				brandNames.join ', '

			onChainClick : (chains)->
				CategoriesAPI.subCategories 'set', chains.category.children
				App.navigate 'brands', categoryID: chains.subCategory.id

			removeItemFromChains : (subCategoryId)->
				@categoryChains = CategoriesAPI.categoryChains 'get'
				spliceIndex = _.findIndex @categoryChains, (chains)->
					chains.subCategory.id is subCategoryId
				@categoryChains.splice spliceIndex, 1
				
				CategoriesAPI.categoryChains 'set', @categoryChains
				Storage.categoryChains 'set', @categoryChains
						

			
		# $scope.$on '$ionicView.beforeEnter', (event, viewData)->
		# 	if !viewData.enableBack
		# 		viewData.enableBack = true

		# $scope.$on '$destroy', ->
		# 	$scope.view.location.modal.remove()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'my-profile',
			url: '/seller-profile'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'ProfileCtrl'
					templateUrl: 'views/profile/profile.html'
					
]
