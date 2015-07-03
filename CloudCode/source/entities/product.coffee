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
	sortBy =  request.params.sortBy
	ascending = request.params.ascending
	page = parseInt request.params.page
	displayLimit = parseInt request.params.displayLimit
	
	brand = request.params.brand

	categoryBasedProducts = []

	# get all category based products
	ProductItem = Parse.Object.extend("ProductItem")
	
	# query to get specific category
	innerQuery = new Parse.Query("Category")
	innerQuery.equalTo("objectId",categoryId)

	# query to get products matching the child category
	query = new Parse.Query("ProductItem");
	query.matchesQuery("category", innerQuery)

	# filter based on brand only if specific brand is fetched
	if brand isnt 'all'
		innerBrandQuery = new Parse.Query("Brand")
		innerBrandQuery.equalTo("objectId",brand)
		query.matchesQuery("brand", innerBrandQuery)
	

	# restrict which fields are being returned
	query.select("image,name,mrp,brand")

	query.include("brand")
	# query.include("category")
	# query.include("attrs")
	# query.include("attrs.attribute")

	# pagination
	query.limit(displayLimit)
	query.skip(page * displayLimit)

	# sorting
	if ascending is true
		query.ascending(sortBy)
	else
		query.descending(sortBy)

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
			filters: []
			sortableAttributes : ["mrp","popularity"]

		response.success result

	queryFindPromise.fail (error) =>
		response.error error.message
	

	

	




