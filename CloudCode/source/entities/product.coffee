Parse.Cloud.job 'productImport', (request, response) ->

	ProductItem = Parse.Object.extend('ProductItem')

	productSavedArr = []

	products =  request.params.products

	_.each products, (product) ->
		productItem = new ProductItem()
		productItem.set "name", product.name
		productItem.set "images", product.images
		productItem.set "model_number", product.model_number
		productItem.set "mrp", parseInt product.mrp
		productItem.set "popularity", product.popularity
		productItem.set "group", product.group

		# set product category
		categoryObj = 
			"__type" : "Pointer",
			"className":"Category",
			"objectId":product.category

		productItem.set "category", categoryObj	
		
		# set brand
		brandObj =
			"__type" : "Pointer",
			"className":"Brand",
			"objectId":product.brand					

		productItem.set "brand", brandObj	
		
		attributeValueArr = []
		attributes = product.attrs

		_.each attributes, (attributeId) ->
			attribObj = 
				"__type" : "Pointer",
				"className":"AttributeValues",
				"objectId":attributeId

			attributeValueArr.push(attribObj)

		productItem.set "attrs", attributeValueArr						


		productSavedArr.push(productItem)
		

	# save all the newly created objects
	Parse.Object.saveAll productSavedArr,
	  success: (objs) ->
	    response.success "Successfully added the products"
	    return
	  error: (error) ->
	    response.error "Failed to add products due to - #{error.message}"


Parse.Cloud.define 'getProducts', (request, response) ->
  
	categoryId = request.params.categoryId
	selectedFilters = request.params.selectedFilters
	sortBy = parseInt request.params.sortBy
	offset = parseInt request.params.offset
	limit = parseInt request.params.limit
	brand = request.params.brandId

	categoryBasedProducts = []

	# get all category based products
	ProductItem = Parse.Object.extend("ProductItem")
	allProductsQuery = new Parse.Query(ProductItem)
	
	innerQuery = new Parse.Query("Category")
	innerQuery.equalTo("objectId",categoryId)

	query = new Parse.Query("ProductItem");
	query.matchesQuery("category", innerQuery)
	query.include("category")
	query.include("brand")
	query.include("attrs")
	query.include("attrs.attribute")

	# pagination
	page = offset
	displayLimit = limit
	query.limit(displayLimit)
	query.skip(page * limit)

	queryFindPromise =query.find()

	# ProductCollection = Parse.Collection.extend({
	#     model: ProductItem,
	#     query: query
	# });

	# @productCollection = new ProductCollection()

	# queryFindPromise = @productCollection.fetch()	

	queryFindPromise.done (products) =>
		result = 
			count: products.length
			products: products
		response.success products

	queryFindPromise.fail (error) =>
		response.error error.message
	

	

	




