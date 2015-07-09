Parse.Cloud.define 'makeRequest' , (request, response) ->

    customerId = request.params.customerId
    productId = request.params.productId
    categoryId = request.params.categoryId 
    brandId = request.params.brandId 
    location = request.params.location  
     
    address = request.params.address 

    comments = request.params.comments
    
    status = request.params.status # 'open' initially
    deliveryStatus = request.params.deliveryStatus 

    Request = Parse.Object.extend('Request')

    request = new Request()

    # set address geo point
    point = new Parse.GeoPoint location

    request.set "addressGeoPoint", point
    request.set "address", address
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
            city = requestObject.get("address").city

            sellersArray = []

            getCategoryBasedSellers(point,categoryId,brandId,city)
            .then (categoryBasedSellers) ->
                console.log categoryBasedSellers
                response.success categoryBasedSellers
                # findQs = []
                # console.log getCategoryBasedSellers.length
                # _.each categoryBasedSellers, (catBasedSeller) ->
                     
                #     sellerId = catBasedSeller.id
                #     sellerGeoPoint = catBasedSeller.get "addressGeoPoint"
                #     sellerRadius = catBasedSeller.get "deliverRadius"

                #     requestQuery = new Parse.Query("Request") 
                #     requestQuery.equalTo("objectId", createdRequestId)
                #     requestQuery.equalTo("customerId", customerObj)
                #     requestQuery.equalTo("status", "open")
                #     requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius)
                    
                #     requestQuery.find()

                #     .then (request)  ->
                #         sellersArray.push sellerId
                #     , (error) ->
                #         response.error "error3 - #{error.message}"

            , (error) ->
                response.error "error2 - #{error.message} #{city}"

        , (error)->
            response.error "error1 - #{error.message}"    




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



