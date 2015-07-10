getCategoryBasedSellers = (geoPoint,categoryId,brandId,city,area) ->

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
    sellerQuery.equalTo("city", city)
    sellerQuery.equalTo("area", area)
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

getAreaBoundSellers = (sellerId,sellerGeoPoint,sellerRadius,createdRequestId,customerObj) ->
    
    requestQuery = new Parse.Query("Request") 
    requestQuery.equalTo("objectId", createdRequestId)
    requestQuery.equalTo("customerId", customerObj)
    requestQuery.equalTo("status", "open")
    requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius)

    promise = new Parse.Promise()
    
    requestQuery.find()
    .then (requests) ->
        if requests.length is 0
            promise.resolve()
        else
            promise.resolve(sellerId)
    , (error) ->
        promise.reject (error)


    promise    

  



Parse.Cloud.define 'createTestSeller', (request, response) ->
    addressGeoPoint = new Parse.GeoPoint request.params.addressLocation
    userData =
        'username': request.params.username
        'password':request.params.password
        'email': request.params.email
        'addressGeoPoint' : addressGeoPoint
        'address' : request.params.address
        'city' : request.params.city
        'deliveryRadius' : request.params.deliveryRadius

    supportedCategoriesArr = []
    supportedCategories = request.params.supportedCategories 

    _.each supportedCategories, (catId) ->
        catObj = 
            "__type" : "Pointer",
            "className":"Category",
            "objectId":catId

        supportedCategoriesArr.push(catObj) 

    userData["supportedCategories"] = supportedCategoriesArr

    supportedBrandsArr = []
    supportedBrands = request.params.supportedBrands

    _.each supportedBrands, (brandId) ->
        brandObj = 
            "__type" : "Pointer",
            "className":"Brand",
            "objectId":brandId

        supportedBrandsArr.push(brandObj) 

    userData["supportedBrands"] = supportedBrandsArr
    userData["userType"] = "seller"    

    user = new Parse.User userData

    # create user with user.signUp method instead of save method
    #  it also checks to make sure that both the username and email are unique
    #  New Parse.Users should always be created using the signUp method. Subsequent updates to a user can be done by calling save
    user.signUp()
        .done (user)=>
            response.success user
        .fail (error) =>
            response.error "Failed to create user #{error.message}"     





