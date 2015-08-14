getCategoryBasedSellers = (categoryId,brandId,city,area) ->

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
            promise.resolve()
        else
            promise.resolve(sellers)
    , (error) ->
        promise.reject(error)

    promise

getAreaBoundSellers = (sellerId,sellerGeoPoint,sellerRadius,createdRequestId) ->
    
    requestQuery = new Parse.Query("Request") 
    requestQuery.equalTo("objectId", createdRequestId)
    # requestQuery.equalTo("customerId", customerObj)
    # requestQuery.equalTo("status", "open")
    requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius)

    promise = new Parse.Promise()
    
    requestQuery.find()
    .then (requests) ->
        if requests.length is 0
            promise.resolve()
        else
            seller = 
                sellerId : sellerId 
                sellerGeoPoint : sellerGeoPoint 
            promise.resolve(seller)
    , (error) ->
        promise.reject (error)


    promise    

  
Parse.Cloud.define 'getLocationBasedSellers' , (request, response) ->
    
    locationGeoPoint = 
        "latitude" : request.params.location.latitude
        "longitude" : request.params.location.longitude

    categoryId = request.params.categoryId
    brandId = request.params.brandId
    city = request.params.city
    area = request.params.area


    Request = Parse.Object.extend('LocationRequests')

    tempRequest = new Request()

    # set address geo point
    point = new Parse.GeoPoint locationGeoPoint

    tempRequest.set "addressGeoPoint", point
    tempRequest.set "city", city
    tempRequest.set "area", area

    # set category
    categoryObj =
        "__type" : "Pointer",
        "className":"Category",
        "objectId":categoryId                    

    tempRequest.set "category", categoryObj    

    # set brand
    brandObj =
        "__type" : "Pointer",
        "className":"Brand",
        "objectId":brandId                    

    tempRequest.set "brand", brandObj       

    tempRequest.save()
        .then (requestObject)->

            createdRequestId = requestObject.id
            city = requestObject.get("city")
            area = requestObject.get("area")

            sellersArray = []

            getCategoryBasedSellers(categoryId,brandId,city,area)
            .then (categoryBasedSellers) ->
                # findQs = []
                # console.log getCategoryBasedSellers.length

                findQs = []

                findQs = _.map(categoryBasedSellers, (catBasedSeller) ->
                    
                    sellerId = catBasedSeller.id
                    sellerGeoPoint = catBasedSeller.get "addressGeoPoint"
                    sellerRadius = catBasedSeller.get "deliveryRadius"

                    getAreaBoundSellers(sellerId,sellerGeoPoint,sellerRadius,createdRequestId)
                )

                Parse.Promise.when(findQs).then ->
                    # delete temporary request and send result data
                    requestObject.destroy() 
                    locationBasedSellers = _.flatten(_.toArray(arguments)) 
                    response.success locationBasedSellers 

                , (error) ->
                    response.error error   


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

Parse.Cloud.define 'updateSellerRating', (request, response) ->
    customerId = request.params.customerId
    sellerId = request.params.sellerId
    ratingInStars = request.params.ratingInStars
    comments = request.params.comments

    # make an entry in ratings table

    Ratings = Parse.Object.extend("Ratings")
    ratings = new Ratings()

    customer = new Parse.User 
    customer.id = customerId

    seller = new Parse.User 
    seller.id = sellerId

    ratings.set "ratingBy" , customer 
    ratings.set "ratingForType" , "seller" 
    ratings.set "ratingFor" , seller 
    ratings.set "count" , ratingInStars 
    ratings.set "comments" , comments

    ratings.save()
    .then (ratingObj) ->
        querySeller = new Parse.Query(Parse.User)
        querySeller.equalTo("objectId", sellerId)

        querySeller.first()
        .then (sellerObj) ->
            # get current rating sum and rating count

            currentRatingSum = sellerObj.get("ratingSum")
            currentRatingCount = sellerObj.get("ratingCount")

            newRatings = currentRatingSum + ratingInStars

            sellerObj.set "ratingSum" , newRatings
            sellerObj.increment("ratingCount")

            sellerObj.save() 
            .then (updatedSeller) ->
                ratingSum = updatedSeller.get("ratingSum")
                ratingCount = updatedSeller.get("ratingCount")
                avgRatings = ratingSum/ratingCount

                result =
                    "sellerId" : sellerId
                    "avgRatings" : avgRatings
                
                response.success result    
            , (error) ->
                response.error error     

    , (error) ->
        response.error error 





        





