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
				@getCreditDetails()
				@categoryChains = CategoryChains

			getCreditDetails : ->
				User.update()
				.then (user)=>
					@setCreditDetails user
				, (error)=>
					@setCreditDetails User.getCurrent()

			setCreditDetails : (user)->
				$scope.$apply =>
					totalCredit = user.get 'addedCredit'
					usedCredit  = user.get 'subtractedCredit'
					@creditAvailable = parseInt(totalCredit) - parseInt(usedCredit)
				
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
				if @categoryChains.length == 0
					CToast.show 'Please choose atleast one category'
				else
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
						BussinessDetails : ($q, Storage)->
							defer = $q.defer()
							Storage.bussinessDetails 'get'
							.then (details) ->
								defer.resolve details

							defer.promise
						
						CategoryChains : ($q, Storage, CategoriesAPI, App)->
							defer = $q.defer()
							categoryChains = CategoriesAPI.categoryChains 'get'
							modifiableStates = ['brands', 'business-details', 'categories']
							if _.contains modifiableStates, App.currentState
								defer.resolve categoryChains
							else
								Storage.categoryChains 'get'
								.then (chains) ->
									CategoriesAPI.categoryChains 'set', chains
									defer.resolve chains
							
							defer.promise
]
