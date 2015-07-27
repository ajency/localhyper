angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal'
	, '$timeout', 'App', 'CToast', 'UIMsg', '$ionicLoading', '$ionicPlatform', 'CDialog'
	, ($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg
	, $ionicLoading, $ionicPlatform, CDialog)->

		$scope.view =
			title: Product.subCategoryTitle
			gotAllProducts: false
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
				originalValues: {}
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
					else if max <= 25000 then increment = 5000
					else if max <= 50000 then increment = 10000
					else if max <= 75000 then increment = 15000
					else if max <= 100000 then increment = 20000
					else increment = 25000
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
					@allAttributes.push value: 'brand', name: 'Brand', selected: 0
					@allAttributes.push value: 'price', name: 'Price', selected: 0

					_.each other.filters, (filter)=>
						value = filter.filterName
						@attrValues[value] = filter.values
						@allAttributes.push
							value: value
							name: s.humanize(filter.attributeName)
							selected: 0

					# De-select all attr values
					_.each @attrValues, (values)->
						_.each values, (val)-> val.selected = false

				showAttrCount : ->
					_.each @attrValues, (values, index)=>
						count = 0
						_.each values, (val)-> count++ if val.selected
						attrIndex = _.findIndex @allAttributes, (attrs)-> attrs.value is index
						@allAttributes[attrIndex].selected = count

				clearFilters : ->
					_.each @attrValues, (values)->
						_.each values, (val)-> val.selected = false

					_.each @allAttributes, (attrs)-> attrs.selected = 0

					@selectedFilters = 
						brands:[]
						price:[]
						otherFilters: {}

				resetFilters : ->
					@attribute = 'brand'
					@clearFilters()

				noChangeInSelection : ->
					_.isEqual _.sortBy(@originalValues), _.sortBy(@attrValues)

				openModal : ->
					@originalValues = JSON.parse JSON.stringify(@attrValues)
					@modal.show()

				closeModal : ->
					if @noChangeInSelection()
						@modal.hide()
					else
						msg = 'Your filter selection will go away'
						CDialog.confirm 'Exit Filter?', msg, ['Exit Anyway', 'Apply & Exit']
						.then (btnIndex)=>
							switch btnIndex
								when 1
									@attrValues = @originalValues
									@showAttrCount()
									@modal.hide()
								when 2
									@onApply()

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
					
					@modal.hide()
					$scope.view.reFetch()
					


			init : ->
				@loadFiltersModal()

			reset : ->
				@footer = false
				@sortBy = 'popularity'
				@ascending = true
				@filter.resetFilters()
				@reFetch false

			reFetch : (refresh=true)->
				@refresh = refresh
				@page = 0
				@products = []
				@canLoadMore = true
				@gotAllProducts = false
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
					@gotAllProducts = false
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
				CToast.showLong UIMsg.serverError
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

				@gotAllProducts = true if !@canLoadMore

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

