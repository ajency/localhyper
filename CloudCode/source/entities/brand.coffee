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


Parse.Cloud.define 'brandImport', (request, response) ->
    Brand = Parse.Object.extend('Brand')
    
    brandsSavedArr = []

    brands =  request.params.brands
    categoryId =  request.params.categoryId

    _.each brands, (brandObj) ->
        brand = new Brand()

        if (brandObj.objectId isnt "") 
            brand.id = brandObj.objectId

        
        brand.set "name", brandObj.name

        image = 
        	"src" : brandObj.imageUrl

        brand.set "image", image

        brandsSavedArr.push(brand)
        

    # save all the newly created objects
    Parse.Object.saveAll brandsSavedArr,
      success: (objs) ->
        successObj = 
            success: true
            message: "Successfully added/updated the brand values"
        response.success successObj

      error: (error) ->
        response.error "Failed to add/update attributes due to - #{error.message}"    	
