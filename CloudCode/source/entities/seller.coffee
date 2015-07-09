getCategoryBasedSellers = (geoPoint,categoryId,brandId) ->

    # find all sellers from users class whose categories column contains categoryId 
    sellerQuery = new Parse.Query(Parse.User) 

    # where categoryId is present in supportedCategories array of sellers
    Category = Parse.Object.extend("Category")
    categoryPointer = new Category()
    categoryPointer.id = categoryId

    Brand = Parse.Object.extend("Brand")
    brandPointer = new Brand()
    brandPointer.id = brandId

    sellerQuery.equalTo("userType", "seller")
    sellerQuery.equalTo("supportedCategories", categoryPointer)
    sellerQuery.equalTo("supportedBrands", brandPointer)

    promise = new Parse.Promise()

    sellerQuery.find()
   
    .then (sellers) ->
        if sellers.length is 0
            errorObj =
                message: "No seller found"
            promise.reject(errorObj)
        else
            promise.resolve(sellers)
    , (error) ->
        promise.reject(error)

    promise

Parse.Cloud.define 'createTestSeller', (request, response) ->
	userData =
		'username': request.params.username
		'password':request.params.password
		'email': request.params.email

	user = new Parse.User userData
	user.set "userType", "seller"

	# create user with user.signUp method instead of save method
	#  it also checks to make sure that both the username and email are unique
	#  New Parse.Users should always be created using the signUp method. Subsequent updates to a user can be done by calling save
	user.signUp()
		.done (user)=>
			response.success user
		.fail (error) =>
			response.error "Failed to create user #{error.message}"		





