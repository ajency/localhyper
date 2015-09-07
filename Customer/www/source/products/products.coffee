angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', 'ProductsAPI', '$stateParams', 'Product', '$ionicModal'
	, '$timeout', 'App', 'CToast', 'UIMsg', '$ionicLoading', '$ionicPlatform', 'CDialog', 'PrimaryAttribute'
	, ($scope, ProductsAPI, $stateParams, Product, $ionicModal, $timeout, App, CToast, UIMsg
	, $ionicLoading, $ionicPlatform, CDialog, PrimaryAttribute)->

		$scope.view =
			title: Product.subCategoryTitle
			primaryAttribute: PrimaryAttribute
			footer: false
			gotAllProducts: false
			products: []
			other: []
			page: 0
			canLoadMore: false
			refresh: false
			search: ''
			
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

				loadModal : ->
					$ionicModal.fromTemplateUrl 'views/products/filters.html', 
						scope: $scope,
						animation: 'slide-in-up'
						hardwareBackButtonClose: false
					.then (modal)=>
						@modal = modal

				getPriceRange : (priceRange)->
					prices = []
					min = priceRange[0]
					max = priceRange[1]

					range = max / min 
					
					divideValue = Math.round(range)

					if divideValue > 1
					
						if divideValue > 10
							divideValue = 10 
							
						intervalValue = Math.round(( max - min ) / divideValue)

						if intervalValue < min
							intervalValue = min

						intervalValueCharacter = intervalValue.toString()

						firstDigit = intervalValueCharacter.substring(0, 1)

						firstDigit = parseInt(firstDigit) + 1

						firstDigit = firstDigit.toString()

						for i in [0...intervalValueCharacter.length-1]
								firstDigit +='0'

						increment = parseInt(firstDigit)

						priceRange = _.range 0, max, increment
						
						_.each priceRange, (start, index)->
							end = priceRange[index+1]
							end = start + increment if _.isUndefined(end)
							if(start == 0)
								prices.push 
									start: start
									end: end
									name: "Below - Rs #{end}"
							else 	
								prices.push 
									start: start
									end: end
									name: "Rs #{start} - Rs #{end}"
					else
						max =  (10 - max % 10 ) + max
						prices.push 
							start: 0
							end: max
							name: "Below - Rs #{max}"
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
					
					@setExcerpt()
					@modal.hide()
					$scope.view.reFetch()

				setExcerpt : ->
					filterNames = []
					_.each @allAttributes, (attr, index)=>
						filterNames.push(attr.name) if attr.selected > 0
					@excerpt = filterNames.join ', '

				isNotNA: (name)->
					name = name.replace /[^a-zA-Z ]/g, ""
					name = name.toLowerCase()
					name isnt 'na'

				orderBy : ->
					(obj)->
						name = parseFloat obj.name
						if _.isNaN name
							obj.name
						else name



			
			init : ->
				@filter.loadModal()
			
			beforeReset : ->
				@sortBy = 'popularity'
				@sortName = 'Popularity'
				@ascending = false
				@filter.excerpt = ''
				@filter.resetFilters()
				@pullToRefresh = false
				@footer = false

			forSearch : ->
				@beforeReset()
				@search = ''
				@canLoadMore = false
				@gotAllProducts = false

			reset : ->
				@beforeReset()
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

			onScrollComplete : ->
				$scope.$broadcast 'scroll.infiniteScrollComplete'
			
			onRefreshComplete : ->
				$scope.$broadcast 'scroll.refreshComplete'
			
			onPullToRefresh : ->
				if App.isOnline()
					@gotAllProducts = false
					@canLoadMore = false
					@page = 0
					@refresh = true
					@getProducts()
				else
					@onRefreshComplete()
					CToast.show UIMsg.noInternet

			onInfiniteScroll : ->
				@refresh = false
				@getProducts()

			onSearch : ->
				if @search is ''
					CToast.show 'Please provide input'
				else
					@reFetch()

			getWordsFromSentence : ->
				wordArr = []
				sentence = @search
				sentence = sentence.replace /[^a-zA-Z0-9.]/g, " "
				sentence = sentence.trim() 
				wordArr = sentence.split /\s+/g
				wordArr = _.map wordArr, (word)-> word.toLowerCase()
				wordArr = _.unique wordArr

				stopWords = ["the" , "is" , "and"]
				
				words = _.filter wordArr, (word) ->
					!_.contains stopWords, word
				words

			getSearchKeyWords : ->
				if App.currentState is 'products' then 'all'
				else @getWordsFromSentence()

			getProducts : ->
				options = 
					categoryID: $stateParams.categoryID
					page: @page
					sortBy: @sortBy
					ascending: @ascending
					selectedFilters: @filter.selectedFilters
					displayLimit: 24
					searchKeywords: @getSearchKeyWords()

				ProductsAPI.getAll options
				.then (data)=>
					@onSuccess data, options.displayLimit
					@footer = true
				, (error)=>
					@onError error
				.finally =>
					@page = @page + 1
					@pullToRefresh = true
					@onRefreshComplete()
					App.resize()

			onError : (error)->
				CToast.showLong UIMsg.serverError
				@canLoadMore = false
			
			onSuccess : (data, displayLimit)->
				@other = data
				if _.isEmpty @filter.attrValues['brand']
					@filter.setAttrValues() 

				_products = data.products
				productsSize = _.size _products
				if productsSize > 0
					if productsSize < displayLimit
						@canLoadMore = false
					else
						@canLoadMore = true
						@onScrollComplete()
					
					if @refresh
						@products = []
						@products = _products
					else 
						@products = @products.concat _products
				else
					@canLoadMore = false

				@gotAllProducts = true if !@canLoadMore

			onSort : (sortBy, sortName, ascending)->
				$ionicLoading.hide()

				switch sortBy
					when 'popularity'
						if @sortBy isnt 'popularity'
							@sortBy = 'popularity'
							@sortName = sortName
							@ascending = ascending
							@reFetch()
					when 'mrp'
						if @sortBy isnt 'mrp'
							@sortBy = 'mrp'
							@sortName = sortName
							@ascending = ascending
							@reFetch()
						else if @ascending isnt ascending
							@sortBy = 'mrp'
							@sortName = sortName
							@ascending = ascending
							@reFetch()

			onIonicLoadingHide : ->
				$ionicLoading.hide()

		
		onDeviceBack = ->
			filter = $scope.view.filter
			if $('.loading-container').hasClass 'visible'
				$ionicLoading.hide()
			else if filter.modal.isShown()
				filter.closeModal()
			else
				App.goBack -1

		$scope.$on '$ionicView.beforeEnter', ->
			App.search.categoryID = $stateParams.categoryID
			if App.currentState is 'products-search'
				$scope.view.forSearch()
				if App.previousState isnt 'single-product'
					$scope.view.products = []
					
			else if _.contains ['categories', 'sub-categories'], App.previousState
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

		.state 'products-search',
			url: '/products-search:categoryID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/products-search.html'
					controller: 'ProductsCtrl'
					resolve:
						Product: ($stateParams, CategoriesAPI)->
							subCategories = CategoriesAPI.subCategories 'get'
							childCategory = _.filter subCategories, (category)->
								category.id is $stateParams.categoryID
							
							subCategoryTitle: childCategory[0].name 
]
