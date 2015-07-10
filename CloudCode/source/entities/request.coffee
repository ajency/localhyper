Parse.Cloud.define 'makeRequest' , (request, response) ->

    customerId = request.params.customerId
    productId = request.params.productId
    categoryId = request.params.categoryId 
    brandId = request.params.brandId 
    location = request.params.location  
     
    address = request.params.address 
    city = request.params.city
    area = request.params.area

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
    request.set "city", city
    request.set "area", area

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

    # set category
    categoryObj =
        "__type" : "Pointer",
        "className":"Category",
        "objectId":categoryId                    

    request.set "category", categoryObj    

    # set brand
    brandObj =
        "__type" : "Pointer",
        "className":"Brand",
        "objectId":brandId                    

    request.set "brand", brandObj       

    request.save()
        .then (requestObject)->

            createdRequestId = requestObject.id
            city = requestObject.get("city")
            area = requestObject.get("area")

            sellersArray = []

            getCategoryBasedSellers(point,categoryId,brandId,city,area)
            .then (categoryBasedSellers) ->
                # findQs = []
                # console.log getCategoryBasedSellers.length

                findQs = []

                findQs = _.map(categoryBasedSellers, (catBasedSeller) ->
                    
                    sellerId = catBasedSeller.id
                    sellerGeoPoint = catBasedSeller.get "addressGeoPoint"
                    sellerRadius = catBasedSeller.get "deliveryRadius"

                    getAreaBoundSellers(sellerId,sellerGeoPoint,sellerRadius,createdRequestId,customerObj)
                )

                Parse.Promise.when(findQs).then ->
                    locationBasedSellerIds = _.flatten(_.toArray(arguments))
                    notificationSavedArr = []
                    _.each locationBasedSellerIds , (locationBasedSellerId) ->
                        if locationBasedSellerId
                            sellerObj =
                                "__type" : "Pointer",
                                "className":"_User",
                                "objectId":locationBasedSellerId  

                            # create entry in notification class
                            notificationData = 
                                hasSeen: false
                                recipientUser: customerObj
                                channel : 'push'
                                processed : false
                                type : "Request"
                                typeId : requestObject.id

                            Notification = Parse.Object.extend("Notification") 
                            notification = new Notification notificationData
                            notificationSavedArr.push(notification)

                    # save all the newly created objects
                    Parse.Object.saveAll notificationSavedArr
                    .then (objs) ->
                        response.success objs
                    , (error) ->
                        response.error (error)                        
                        
                , (error) ->
                    response.error (error)

            , (error) ->
                response.error (error)

        , (error)->
            response.error (error)  


Parse.Cloud.define 'getNewRequests' ,(request, response) ->
    # get all requests that have following criteria satisfied for a seller:
        # categories sold by that seller 
        # brands sold by that seller 
        # within the catchement area of the seller 
        # have not expired 
        # have status open
        # offer has not been made by the seller for the request

    sellerId = request.params.sellerId
    # categories = request.params.categoryId 
    # brands = request.params.brandId
    city = request.params.city
    sellerLocation = request.params.sellerLocation  
    sellerRadius = request.params.sellerRadius
    currentTimeStamp = request.params.currentTimeStamp
    status = "open"

    # find categories and brands supported by the seller
    sellerQuery = new Parse.Query(Parse.User)
    sellerQuery.equalTo("objectId", sellerId)
    sellerQuery.include("supportedCategories")
    sellerQuery.include("supportedBrands")

    sellerQuery.first()
    .then (sellerObject) ->
        sellerCategories = sellerObject.get("supportedCategories")
        sellerBrands = sellerObject.get("supportedBrands")

        requestQuery = new Parse.Query("Request")
        requestQuery.containedIn("category",sellerCategories)
        requestQuery.containedIn("brand",sellerBrands)

        # get all requests having any of the above categories and brands
        # requestQuery = new Parse.Query("Request")
        # findCategoryQs = []

        # findCategoryQs = _.map(sellerCategories, (sellerCategory) ->
            
        #     catId = sellerCategory.id
        #     Category = Parse.object.extend("Category")
        #     categoryObj = new Category()
        #     categoryObj.id = catId

        #     filters = 
        #         category : categoryObj

        #     getFilteredRequests(filters,"Request")
        # ) 

        # Parse.Promise.when(findCategoryQs).then ->       
        #     response.success(arguments)
        
        # , (error) ->
        #     response.error (error)
        requestQuery.find()
        .then (requests) ->
            response.success (requests)
        , (error) ->
            response.error (error)
    , (error) ->
        response.error (error)


getFilteredRequests = (filters,className)->
    query = new Parse.Query(className)

    # get filter keys and append constraints on the query accordingly
    filterKeys = _.allKeys(filters)

    _.each filterKeys , (filterKey) ->
        query.equalTo(filterKey,filters[filterKey])

    query.find()







