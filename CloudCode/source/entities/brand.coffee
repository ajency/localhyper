Parse.Cloud.define 'getCategoryBasedBrands', (request, response) ->
	categoryId = request.params.categoryId

	queryCategory = new Parse.Query("Category")

	queryCategory.equalTo("objectId",categoryId)
	queryCategory.include("supported_brands")
	queryCategory.select("supported_brands")
	
	queryCategory.first()

	.then (category) ->
		response.success category
	, (error) ->
		response.error "Error - #{error.message}"
