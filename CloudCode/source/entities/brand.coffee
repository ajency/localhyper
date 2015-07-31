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
        
        if !_.isNull(brandObj.name) 
            brand = new Brand()

            if !_.isNull(brandObj.objectId) 
                brand.id = brandObj.objectId

            
            brand.set "name", brandObj.name

            image = 
            	"src" : brandObj.imageUrl

            brand.set "image", image

            brandsSavedArr.push(brand)
        

    # save all the newly created objects
    Parse.Object.saveAll brandsSavedArr,
      success: (objs) ->
        # get category and update its filterable column
        Category = Parse.Object.extend('Category')
        category = new Category()
        category.id = categoryId

        
        category.set "supported_brands" , objs  

        category.save()
        .then (categoryObj)->
            successObj = 
                success: true
                message: "Successfully added/updated the brands"
            response.success successObj
        , (error) ->
            response.error error

      error: (error) ->
        response.error error	
