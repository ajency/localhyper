angular.module 'LocalHyper.brands', []


.controller 'BrandsCtrl', ['$scope', 'BrandsAPI', '$stateParams', 'SubCategory'
	, 'CToast', 'CategoriesAPI', 'App'
	, ($scope, BrandsAPI, $stateParams, SubCategory, CToast, CategoriesAPI, App)->

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

			onDone : ->
				atleastOneSelected = false
				_.each @brands, (brand)->
					if brand.selected then atleastOneSelected = true

				@categoryChains = CategoriesAPI.categoryChains 'get'
				if _.isEmpty @categoryChains
					if !atleastOneSelected
						CToast.show 'Please select atleast one brand'
					else
						@setCategoryChains true
				else @setCategoryChains false

			setCategoryChains : (empty)->
				CategoriesAPI.getAll()
				.then (allCategories)=>
					parentCategory = _.filter allCategories, (category)->
						category.id is SubCategory.parent

					selectedBrands = _.filter @brands, (brand)->
						brand.selected is true

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
						_.each @categoryChains, (chains, index)=>
							if chains.subCategory.id is SubCategory.id
								existingChain = true
								@categoryChains[index].brands = selectedBrands
						
						if !existingChain
							@categoryChains.push chain
							
						CategoriesAPI.categoryChains 'set', @categoryChains

					App.navigate 'category-chains'
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
