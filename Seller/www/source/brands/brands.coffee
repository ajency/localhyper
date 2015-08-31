angular.module 'LocalHyper.brands', []


.controller 'BrandsCtrl', ['$scope', 'BrandsAPI', '$stateParams', 'SubCategory'
	, 'CToast', 'CategoriesAPI', 'App', 'CDialog', 'Storage', 'User'
	, ($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App
	, CDialog, Storage, User)->

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
				@setBrandSelection()

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

				@setSelectAll()

			setSelectAll : ->
				selected = _.pluck @brands, 'selected'
				@selectAll = !_.contains selected, false

			onSelectAll : ->
				@selectAll = !@selectAll
				if @selectAll
					_.each @brands, (brand)-> brand.selected = true
				else
					_.each @brands, (brand)-> brand.selected = false

			onDone : ->
				CategoriesAPI.getAll()
				.then (allCategories)=>
					parentCategory = _.filter allCategories.data, (category)-> category.id is SubCategory.parent
					selectedBrands = _.filter @brands, (brand)-> brand.selected is true
					minOneBrandSelected = if _.size(selectedBrands) is 0 then false else true

					data = []
					chain = 
						category: parentCategory[0]
						subCategory: SubCategory
						brands: selectedBrands
					data.push chain

					if @isCategoryChainsEmpty()
						@categoryChains = if minOneBrandSelected then data else []
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
							if btnIndex is 1 then @beforeGoBack()
					else @beforeGoBack()

			beforeGoBack : ->
				if User.isLoggedIn()
					CategoriesAPI.categoryChains 'set', @categoryChains
					@goBack()
				else
					CategoriesAPI.categoryChains 'set', @categoryChains 
					Storage.categoryChains 'set', @categoryChains
					.then =>
						@goBack()

			goBack : ->
				switch App.previousState
					when 'categories' then count = -2
					when 'sub-categories' then count = -3
					when 'category-chains' then count = -1
					when 'my-profile' then count = -1
					else count = 0
				App.goBack count

		
		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.selectAll = false
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


