angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$q', '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', 'AuthAPI', 'CSpinner', 'CategoryChains'
	, ($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner, CategoryChains)->

		
		$scope.view = 
			showDelete: false
			categoryChains : []

			setCategoryChains : ->
				# Storage.categoryChains 'get'
				# .then (chains) =>
				# 	if !_.isNull chains
				# 		@categoryChains = chains
				# 		CategoriesAPI.categoryChains 'set', chains
				@categoryChains = CategoryChains
				CategoriesAPI.categoryChains 'set', CategoryChains

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
				
				# CategoriesAPI.categoryChains 'set', @categoryChains
				# Storage.categoryChains 'set', @categoryChains

			saveDetails : ->
				CSpinner.show '', 'Please wait...'
				
				CategoriesAPI.categoryChains 'set', @categoryChains
				Storage.categoryChains 'set', @categoryChains

				user = User.info 'get'
				AuthAPI.isExistingUser(user)
				.then (data)=>
					AuthAPI.loginExistingUser(data.userObj)
				.then (success)->
					App.navigate('new-requests')
				, (error)=>
					CToast.show 'Please try again data not saved'
				.finally ->
					CSpinner.hide()


		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
			
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
					resolve :
						CategoryChains : ($q, Storage)->
							defer = $q.defer()
							Storage.categoryChains 'get'
							.then (chains) ->
								defer.resolve chains
							defer.promise

					
]
