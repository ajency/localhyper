angular.module 'LocalHyper.brands', []


.controller 'BrandsCtrl', ['$scope', 'BrandsAPI', '$stateParams', 'SubCategory'
	, 'CToast', 'CategoriesAPI', 'App', 'CDialog'
	, ($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App, CDialog)->

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

			setCategoryChains : ->
				empty = @isCategoryChainsEmpty()
				CategoriesAPI.getAll()
				.then (allCategories)=>
					parentCategory = _.filter allCategories, (category)-> category.id is SubCategory.parent
					selectedBrands = _.filter @brands, (brand)-> brand.selected is true
					data = []
					chain = 
						category: parentCategory[0]
						subCategory: SubCategory
						brands: selectedBrands
					data.push chain

					if empty
						CategoriesAPI.categoryChains 'set', data
					else
						existingChain = false
						chainIndex = _.findIndex @categoryChains, (chains)->
							chains.subCategory.id is SubCategory.id

						if chainIndex isnt -1 #When existing category chain
							if _.size(selectedBrands) > 0
								@categoryChains[chainIndex].brands = selectedBrands
							else
								@categoryChains.splice chainIndex, 1
						
						# When new existing category chain
						if chainIndex is -1 and _.size(chain.brands) > 0
							@categoryChains.push chain
							
						CategoriesAPI.categoryChains 'set', @categoryChains

			onDone : ->
				@setCategoryChains()
				minOneBrandSelected = !_.isUndefined _.find @brands, (brand)-> brand.selected is true
				empty = @isCategoryChainsEmpty()
				if empty and !minOneBrandSelected
					CToast.show 'Please select atleast one brand'
				else if !empty and !minOneBrandSelected
					CDialog.confirm 'Select Brands', 'You have not selected any brands', ['Continue', 'Cancel']
					.then (btnIndex)=>
						if btnIndex is 1 then App.navigate 'category-chains'
				else
					count = if App.previousState is 'categories' then -2 else -3
					App.goBack count
					# App.navigate 'category-chains'


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
