angular.module 'LocalHyper.brands', []


.controller 'BrandsCtrl', ['$scope', 'BrandsAPI', '$stateParams', 'SubCategory'
	, 'CToast', 'CategoriesAPI', 'App', 'CDialog', 'Storage','User'
	, ($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App, CDialog, Storage, User)->

		$scope.view =
			title: SubCategory.name
			brands: []
			display: 'loader'
			errorType: ''
			categoryChains: null
			
			init: ->
				@getBrands()

			getBrands : ->
				BrandsAPI.getAll $stateParams.categoryID
				.then (data)=>
					console.log data
					@onSuccess data.supported_brands
				, (error)=>
					@onError error
			
			onSuccess : (data)->
				@display = 'noError'
				@brands = data

			onError: (type)->
				@display = 'error'
				@errorType = type

			onTapToRetry : ->
				@display = 'loader'
				@getBrands()

			isCategoryChainsEmpty : ->
				@categoryChains = CategoriesAPI.categoryChains 'get'
				empty = _.isEmpty @categoryChains
				empty

			brandSelection : (brandID)->
				selected = false
				if @isCategoryChainsEmpty()
					selected = false
				else
					chain = _.filter @categoryChains, (chains)-> chains.subCategory.id is SubCategory.id
					if !_.isEmpty chain
						_brands = chain[0].brands
						_brandIds = _.pluck _brands, 'objectId'
						selected = _.contains _brandIds, brandID
					else selected = false
				selected

			setBrandSelection : ->
				if @isCategoryChainsEmpty()
					_.each @brands, (brand)->
						brand.selected = false
				else
					chain = _.filter @categoryChains, (chains)-> chains.subCategory.id is SubCategory.id
					if !_.isEmpty chain
						_brands = chain[0].brands
						_brandIds = _.pluck _brands, 'objectId'
						_.each @brands, (brand)->
							brand.selected = _.contains _brandIds, brand.objectId
					else
						_.each @brands, (brand)-> brand.selected = false

			onDone : ->
				CategoriesAPI.getAll()
				.then (allCategories)=>
					parentCategory = _.filter allCategories, (category)-> category.id is SubCategory.parent
					selectedBrands = _.filter @brands, (brand)-> brand.selected is true
					minOneBrandSelected = if _.size(selectedBrands) is 0 then false else true

					data = []
					chain = 
						category: parentCategory[0]
						subCategory: SubCategory
						brands: selectedBrands
					data.push chain

					if @isCategoryChainsEmpty() then @categoryChains = data
					else
						chainIndex = _.findIndex @categoryChains, (chains)->
							chains.subCategory.id is SubCategory.id

						if chainIndex isnt -1 #When existing category chain
							if minOneBrandSelected
								@categoryChains[chainIndex].brands = selectedBrands
							else
								@categoryChains.splice chainIndex, 1
						
						# When new category chain
						if chainIndex is -1 and minOneBrandSelected
							@categoryChains.push chain

					if !minOneBrandSelected
						CDialog.confirm 'Select Brands', 'You have not selected any brands', ['Continue', 'Cancel']
						.then (btnIndex)=>
							if btnIndex is 1 then @goBack(minOneBrandSelected)
					else @goBack(minOneBrandSelected)

			goBack : (minOneBrandSelected)->
				if User.isLoggedIn() #if user is logged it only sets in category api
					CategoriesAPI.categoryChains 'set', @categoryChains 
					App.navigate 'my-profile'
				else
					if minOneBrandSelected   #if atleast one brand is selected than only set values
						CategoriesAPI.categoryChains 'set', @categoryChains 
						Storage.categoryChains 'set', @categoryChains

					switch App.previousState
						when 'categories' then count = -2
						when 'sub-categories' then count = -3
						when 'category-chains' then count = -1
						when 'my-profile' then count = -1
						else count = 0
					App.goBack count

		
		$scope.$on '$ionicView.beforeEnter', ->
			if $scope.view.display is 'noError'
				$scope.view.setBrandSelection() 
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'brands',
			url: '/brands:categoryID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/brands/brands.html'
					controller: 'BrandsCtrl'
					resolve:
						SubCategory: ($stateParams, CategoriesAPI)->
							subCategories = CategoriesAPI.subCategories 'get'
							childCategory = _.filter subCategories, (category)->
								category.id is $stateParams.categoryID
							
							childCategory[0]
]
