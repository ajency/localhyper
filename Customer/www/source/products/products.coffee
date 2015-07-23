angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal'
	, '$timeout', 'App', 'CToast', 'UIMsg', '$ionicLoading', '$ionicPlatform', 'CDialog'
	, ($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg
	, $ionicLoading, $ionicPlatform, CDialog)->

		$scope.view =
			title: Product.subCategoryTitle
			products: []
			other: []
			page: 0
			footer: false
			canLoadMore: true
			refresh: false
			sortBy: 'popularity'
			ascending: true
			
			filter:
				modal: null
				attribute: 'brand'
				allAttributes: []
				attrValues: {}
				selectedFilters: 
					brands: []
					price: []
					otherFilters: {}

				getPriceRange : (priceRange)->
					prices = []
					min = priceRange[0]
					max = priceRange[1]
					if max <= 1000 then increment = 100
					else if max <= 5000 then increment = 1000
					else increment = 5000
					priceRange = _.range min, max, increment
					_.each priceRange, (start, index)->
						end = priceRange[index+1]
						end = max if _.isUndefined(end)
						prices.push 
							start: start
							end: end
							name: "Rs #{start} - Rs #{end}"
					prices

				setAttrValues: ->
					other = $scope.view.other
					@attrValues['brand'] = other.supportedBrands
					@attrValues['price'] = @getPriceRange other.priceRange
					@allAttributes.push value: 'brand', name: 'Brand'
					@allAttributes.push value: 'price', name: 'Price'

					_.each other.filters, (filter)=>
						value = filter.filterName
						@attrValues[value] = filter.values
						@allAttributes.push
							value: value
							name: s.humanize(filter.attributeName)

				resetFilters : ->
					@attribute = 'brand'
					_.each @attrValues, (attrs)->
						_.each attrs, (val)-> val.selected = false

					@selectedFilters = 
						brands:[]
						price:[]
						otherFilters: {}

				selectionExists : ->
					exists = false
					_.each @attrValues, (attrs)->
						_.each attrs, (val)-> 
							exists = true if val.selected
					exists

				closeModal : ->
					if @selectionExists()
						msg = 'Your filter selection will go away'
						CDialog.confirm 'Exit Filter?', msg, ['Exit Anyway', 'Apply & Exit']
						.then (btnIndex)=>
							switch btnIndex
								when 1
									@modal.hide()
									# @resetFilters()
									$scope.view.reset()
								when 2
									@onApply()
					else @modal.hide()

				onApply : ->
					_.each @attrValues, (_values, attribute)=>
						switch attribute
							when 'price'
								start = []
								end = []
								_.each _values, (price)=>
									if price.selected
										start.push price.start
										end.push price.end
								
								if _.isEmpty(start) then @selectedFilters.price = []
								else @selectedFilters.price = [_.min(start), _.max(end)]

							when 'brand'
								selected = []
								_.each _values, (brand)=>
									selected.push(brand.id) if brand.selected
								@selectedFilters.brands = selected
							
							else
								# When other filters
								selected = []
								_.each _values, (attr)=>
									selected.push(attr.id) if attr.selected
								@selectedFilters.otherFilters[attribute] = selected

					console.log @selectedFilters
					@modal.hide()
					$scope.view.reFetch()
					


			init : ->
				@loadFiltersModal()

			reset : ->
				@products = []
				@page = 0
				@footer = false
				@canLoadMore = true
				@refresh = false
				@sortBy = 'popularity'
				@ascending = true
				@filter.resetFilters()
				@onScrollComplete()

			reFetch : ->
				@page = 0
				@refresh = true
				@products = []
				@canLoadMore = true
				@onScrollComplete()

			showSortOptions : ->
				$ionicLoading.show
					scope: $scope
					templateUrl: 'views/products/sort.html'
					hideOnStateChange: true

			loadFiltersModal : ->
				$ionicModal.fromTemplateUrl 'views/products/filters.html', 
					scope: $scope,
					animation: 'slide-in-up'
					hardwareBackButtonClose: false
				.then (modal)=>
					@filter.modal = modal

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			onRefreshComplete : ->
				$scope.$broadcast 'scroll.refreshComplete'
			
			onPullToRefresh : ->
				if App.isOnline()
					@canLoadMore = true
					@page = 0
					@refresh = true
					@getProducts()
				else
					@onRefreshComplete()
					CToast.show UIMsg.noInternet

			onInfiniteScroll : ->
				@refresh = false
				@getProducts()

			getProducts : ->
				ProductsAPI.getAll
					categoryID: $stateParams.categoryID
					page: @page
					sortBy: @sortBy
					ascending: @ascending
					selectedFilters: @filter.selectedFilters
				.then (data)=>
					console.log data
					@onSuccess data
				, (error)=>
					@onError error
				.finally =>
					@footer = true
					@page = @page + 1
					@onRefreshComplete()

			onError : (error)->
				console.log error
				@canLoadMore = false
			
			onSuccess : (data)->
				@other = data
				if _.isEmpty @filter.attrValues['brand']
					@filter.setAttrValues() 

				_products = data.products
				if _.size(_products) > 0
					if _.size(_products) < 10 then @canLoadMore = false
					else @onScrollComplete()
					if @refresh then @products = _products
					else @products = @products.concat _products
				else
					@canLoadMore = false

			getPrimaryAttrs : (attrs)->
				if !_.isUndefined attrs
					attrs = attrs[0]
					value = s.humanize attrs.value
					unit = ''
					if _.has attrs.attribute, 'unit'
						unit = s.humanize attrs.attribute.unit
					"#{value} #{unit}"
				else ''

			onSort : (sortBy, ascending)->
				$ionicLoading.hide()

				switch sortBy
					when 'popularity'
						if @sortBy isnt 'popularity'
							@sortBy = 'popularity'
							@ascending = true
							@reFetch()
					when 'mrp'
						if @sortBy isnt 'mrp'
							@sortBy = 'mrp'
							@ascending = ascending
							@reFetch()
						else if @ascending isnt ascending
							@sortBy = 'mrp'
							@ascending = ascending
							@reFetch()

		
		onDeviceBack = ->
			filter = $scope.view.filter
			if $('.loading-container').hasClass 'visible'
				$ionicLoading.hide()
			else if filter.modal.isShown()
				filter.closeModal()
			else
				App.goBack -1

		$scope.$on '$ionicView.beforeEnter', ->
			if _.contains ['categories', 'sub-categories'], App.previousState
				$scope.view.reset()

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'products',
			url: '/products:categoryID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/products.html'
					controller: 'ProductsCtrl'
					resolve:
						Product: ($stateParams, CategoriesAPI)->
							subCategories = CategoriesAPI.subCategories 'get'
							childCategory = _.filter subCategories, (category)->
								category.id is $stateParams.categoryID
							
							subCategoryTitle: childCategory[0].name 
]

