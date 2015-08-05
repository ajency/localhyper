angular.module 'LocalHyper.profile', []


.controller 'ProfileCtrl', ['$q', '$scope', 'User', 'App', 'CToast', 'Storage', 'CategoriesAPI', 'AuthAPI', 'CSpinner'
	, 'CategoryChains', '$rootScope'
	, ($q, $scope, User, App, CToast, Storage, CategoriesAPI, AuthAPI, CSpinner, CategoryChains, $rootScope)->

		
		$scope.view = 
			showDelete: false
			categoryChains : []

			setCategoryChains : ->
				@categoryChains = CategoryChains
				
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
				
			saveDetails : ->
				CSpinner.show '', 'Please wait...'
				
				CategoriesAPI.categoryChains 'set', @categoryChains
				Storage.categoryChains 'set', @categoryChains

				defer = $q.defer()
				Storage.bussinessDetails 'get'
				.then (details)->
					User.info 'reset', details
					user = User.info 'get'
					user = User.info 'get'
					AuthAPI.isExistingUser(user)
					.then (data)=>
						AuthAPI.loginExistingUser(data.userObj)
					.then (success)->
						$rootScope.$broadcast 'category:chain:changed'
						App.navigate('new-requests')
					, (error)=>
						CToast.show 'Please try again data not saved'
					.finally ->
						CSpinner.hide()


		$scope.$on '$ionicView.beforeEnter', (event, viewData)->
			if !viewData.enableBack
				viewData.enableBack = true
				
		$scope.$on '$ionicView.enter', ->
			
		

		$scope.$on '$ionicView.leave', ->
			categoryChainSet = true
			Storage.categoryChains 'get'
			.then (chains) ->
				if(App.currentState == 'categories' || App.currentState == 'sub-categories' || App.currentState == 'brands')
					categoryChainSet = false 
				else 
				   categoryChainSet = true

				if categoryChainSet == true
					CategoriesAPI.categoryChains 'set', chains
			
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
						CategoryChains : ($q, Storage,CategoriesAPI)->
						    	chains = CategoriesAPI.categoryChains('get')
						    	defer = $q.defer()
						    	if chains.length == 0
						    		defer = $q.defer()
						    		Storage.categoryChains 'get'
						    		.then (chains) ->
						    			CategoriesAPI.categoryChains 'set', chains
						    			defer.resolve chains
						    	else 
						    		defer.resolve chains

						    	defer.promise
						  
]
