angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$q', '$scope', 'User', 'App', 'CToast', 'Storage'
	, 'CategoriesAPI', 'AuthAPI', 'CSpinner', 'CategoryChains', '$rootScope', 'BussinessDetails'
	, ($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner
	, CategoryChains, $rootScope, BussinessDetails)->
		
		$scope.view = 
			showDelete: false
			categoryChains : []

			init : ->
				@showDelete = false
				@categoryChains = []
				@businessName = BussinessDetails.businessName
				@phone = BussinessDetails.phone
				@name = BussinessDetails.name
				@setCategoryChains()

			setCategoryChains : ->
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

			onChainClick : (chains)->
				CategoriesAPI.subCategories 'set', chains.category.children
				App.navigate 'brands', categoryID: chains.subCategory.id
				
			saveDetails : ->
				Storage.bussinessDetails 'get'
				.then (user)=>
					CSpinner.show '', 'Please wait...'
					User.info 'set', user
					AuthAPI.isExistingUser user
					.then (data)->
						AuthAPI.loginExistingUser data.userObj
					.then (success)=>
						Storage.categoryChains 'set', @categoryChains
						.then =>
							CategoriesAPI.categoryChains 'set', @categoryChains
							$rootScope.$broadcast 'category:chain:updated'
							CSpinner.hide()
							CToast.show 'Saved profile details'
					, (error)->
						CToast.show 'Could not connect to server, please try again.'
						CSpinner.hide()
					
		
		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			# $scope.view.init()
			# scrollTopStates = ['suggest-product', 'credit-history', 'new-requests'
			# 				, 'my-offer-history', 'successful-offers']
			# if _.contains scrollTopStates, App.previousState
			# 	App.scrollTop()

			if !viewData.enableBack
				viewData.enableBack = true

		# $scope.$on '$ionicView.leave', ->
		# 	categoryChainSet = true
		# 	Storage.categoryChains 'get'
		# 	.then (chains) ->
		# 		if(App.currentState == 'categories' || App.currentState == 'sub-categories' || App.currentState == 'brands')
		# 			categoryChainSet = false 
		# 		else 
		# 		   categoryChainSet = true

		# 		if categoryChainSet == true
		# 			CategoriesAPI.categoryChains 'set', chains
]


.config ['$stateProvider', ($stateProvider,Storage,CategoriesAPI)->

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

						BussinessDetails : ($q, Storage)->
							defer = $q.defer()
							Storage.bussinessDetails 'get'
							.then (details) ->
								defer.resolve details

							defer.promise
]
