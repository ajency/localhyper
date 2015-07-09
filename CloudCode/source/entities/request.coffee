getCategoryBasedSellers = (geoPoint,categoryId) ->

    # find all sellers from users class whose categories column contains categoryId 
    sellerQuery = new Parse.Query(Parse.User) 

    # where categoryId is present in supportedCategories array of sellers
    Category = Parse.Object.extend("Category")
    categoryPointer = new Category()
    categoryPointer.id = categoryId
    sellerQuery.equalTo("userType", "seller")
    sellerQuery.equalTo("supportedCategories", categoryPointer)

    promise = new Parse.Promise()

    sellerQuery.find()
    .then (sellers) ->
        promise.resolve(sellers)
    , (error) ->
        promise.reject(error)

    promise





Parse.Cloud.define 'makeRequest' , (request, response) ->

    customerId = request.params.customerId
    productId = request.params.productId
    categoryId = request.params.categoryId 
    location = request.params.location  
     
    addressText = request.params.addressText 

    comments = request.params.comments
    
    status = request.params.status # 'open' initially
    deliveryStatus = request.params.deliveryStatus 

    Request = Parse.Object.extend('Request')

    request = new Request()

    # set address geo point
    point = new Parse.GeoPoint location

    request.set "addressGeoPoint", point
    request.set "addressText", addressText
    request.set "status", status
    request.set "deliveryStatus", deliveryStatus

    # set request's customerId
    customerObj = 
        "__type" : "Pointer",
        "className":"_User",
        "objectId":customerId

    request.set "customerId", customerObj 
    
    # set product
    productObj =
        "__type" : "Pointer",
        "className":"ProductItem",
        "objectId":productId                    

    request.set "productId", productObj  

    request.save()
        .then (requestObject)->

            createdRequestId = requestObject.id

            sellersArray = []

            getCategoryBasedSellers(point,categoryId)
            .then (categoryBasedSellers) ->
                _.each categoryBasedSellers , (catBasedSeller) ->
                    sellerId = catBasedSeller.id
                    sellerGeoPoint = catBasedSeller.get "addressGeoPoint"
                    sellerRadius = catBasedSeller.get "deliverRadius"

                    requestQuery = new Parse.Query("Request") 
                    requestQuery.equalTo("objectId", createdRequestId)
                    requestQuery.equalTo("customerId", customerObj)
                    requestQuery.equalTo("status", "open")
                    requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius)

                    requestQuery.find() 
                    .then (requestObjects) ->
                        if requestObjects.length is 1
                            sellersArray.push sellerId
                        response.success sellersArray

                    , (error)->
                        response.error "Failed due to - #{error.message}"





            # for each seller id create a notification in the background, i.e. saveAll

            # sellerObj =
            #     "__type" : "Pointer",
            #     "className":"_User",
            #     "objectId":sellerId  

            # create entry in notification class
            # notificationData = 
            #     hasSeen: false
            #     recipientUser: customerObj
            #     channel : 'push'
            #     processed : false
            #     type : "Request"
            #     typeId : requestObject.id

            # Notification = Parse.Object.extend("Notification") 
            # notification = new Notification notificationData
            # notification.save() 
            # .then (notificationObj) ->
            #     response.success notificationObj               



