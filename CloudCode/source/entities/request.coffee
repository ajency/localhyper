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

    Request = Parse.Object.extend('Request')

    request = new Request()

    # set address geo point
    point = new Parse.GeoPoint location

    request.set "addressGeoPoint", point
    request.set "address", address
    request.set "status", status
    request.set "city", city
    request.set "area", area
    request.set "comments", comments
    request.set "offerCount", 0

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

    request.set "product", productObj  

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

            getCategoryBasedSellers(categoryId,brandId,city,area)
            .then (categoryBasedSellers) ->
                # findQs = []
                # console.log getCategoryBasedSellers.length

                findQs = []

                findQs = _.map(categoryBasedSellers, (catBasedSeller) ->
                    
                    sellerId = catBasedSeller.id
                    sellerGeoPoint = catBasedSeller.get "addressGeoPoint"
                    sellerRadius = catBasedSeller.get "deliveryRadius"

                    typeOfRequest = "make_request"
                    getAreaBoundSellers(sellerId,sellerGeoPoint,sellerRadius,createdRequestId, typeOfRequest)
                )

                Parse.Promise.when(findQs).then ->
                    locationBasedSellers = _.flatten(_.toArray(arguments))
                    notificationSavedArr = []
                    _.each locationBasedSellers , (locationBasedSeller) ->
                        
                        locationBasedSellerId = locationBasedSeller.sellerId
                        
                        if locationBasedSellerId
                            sellerObj =
                                "__type" : "Pointer",
                                "className":"_User",
                                "objectId":locationBasedSellerId  

                            requestObject = 
                                "__type" : "Pointer",
                                "className":"Request",
                                "objectId":createdRequestId                                

                            # create entry in notification class with recipient as the seller
                            notificationData = 
                                hasSeen: false
                                recipientUser: sellerObj
                                channel : 'push'
                                processed : false
                                type : "Request"
                                requestObject : requestObject

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
        # city and area
        # have status open
        # have not expired i.e created date of request is less than 
        # within the catchement area of the seller 
        # offer has not been made by the seller for the request

    sellerId = request.params.sellerId
    # categories = request.params.categoryId 
    # brands = request.params.brandId
    city = request.params.city
    area = request.params.area
    sellerLocation =  request.params.sellerLocation
    sellerRadius = request.params.sellerRadius
    categories = request.params.categories
    brands = request.params.brands
    productMrp = request.params.productMrp

    requestFilters = 
        "city" : city
        "area" : area
        "sellerLocation" : sellerLocation
        "sellerRadius" : sellerRadius
        "categories" : categories
        "brands" : brands
        "productMrp" : productMrp

    getNewRequestsForSeller(sellerId, requestFilters)
    .then (newRequestResult) ->
        response.success newRequestResult
    , (error) ->
        response.error error


Parse.Cloud.define 'updateRequestStatus' , (request, response) ->
    requestId = request.params.requestId
    status = request.params.status
    failedDeliveryReason = request.params.failedDeliveryReason

    validStatuses = ['pending_delivery', 'sent_for_delivery','failed_delivery','successful','cancelled']
    isValidStatus = _.indexOf(validStatuses, status )

    if isValidStatus > -1 

        Request = Parse.Object.extend('Request')
        request = new Request()

        request.id = requestId

        request.set "status", status

        if status is "failed_delivery"
            request.set "failedDeliveryReason", failedDeliveryReason
        
        request.save() 

        .then (requestObj) ->
            requestStatus = requestObj.get("status")
            requestId = requestObj.id
            requestingCustomer = requestObj.get("customerId")

            console.log "requesting customer"
            console.log requestObj
            
            # send push notiifcations to all sellers to whom a new request notification was sent for this request id
            # get all such sellerObj
            if requestStatus is "cancelled"
                queryNotification = new Parse.Query("Notification")

                innerQueryRequest = new Parse.Query("Request")
                innerQueryRequest.equalTo("objectId" , requestId)
                
                queryNotification.equalTo("type" , "Request")
                queryNotification.matchesQuery("requestObject", innerQueryRequest)
                
                queryNotification.include("recipientUser")
                
                queryNotification.find()
                .then (newReqNotifications)->
                    sellersArr = _.map( newReqNotifications , (newNotification) ->
                        newNotification.get("recipientUser")
                     )

                    notificationSavedArr = []
                    _.each sellersArr , (sellerObj) ->
                        notificationData = 
                            hasSeen: false
                            recipientUser: sellerObj
                            channel : 'push'
                            processed : false
                            type : "CancelledRequest"
                            requestObject : requestObj

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
                    response.error error
            
            else if (requestStatus is "sent_for_delivery") or (requestStatus is 'failed_delivery') or (requestStatus is 'successful')
                
                requestObj.fetch()
                .then (req)->
                    requestingCustomer = requestObj.get("customerId")
                    if requestStatus is "sent_for_delivery"
                        type = "SentForDeliveryRequest"
                    else if requestStatus is "failed_delivery"
                        type = "FailedDeliveryRequest"
                    else if requestStatus is 'successful'
                        type = "SuccessfulRequest"
                    
                    notificationData = 
                        hasSeen: false
                        recipientUser: requestingCustomer
                        channel : 'push'
                        processed : false
                        type : type
                        requestObject : requestObj

                    Notification = Parse.Object.extend("Notification") 
                    notification = new Notification notificationData 
                    notification.save()
                    .then (savedNotification) ->
                        response.success savedNotification
                    , (error) ->
                        response.error error 
                , (error) ->
                    response.error error              

            else
                resultObj = 
                    requestId : requestId
                    requestStatus : requestObj.get("status")
                response.success resultObj

        , (error) ->
            response.error error

    else 
        response.error "Please enter a valid status"

# API for listing of request history for customer
Parse.Cloud.define 'getCustomerRequests' , (request, response) ->
    customerId = request.params.customerId

    productId = request.params.productId

    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit 

    requestType = request.params.requestType     # "expired" , "nonexpired" , "all" 

    selectedFilters = request.params.selectedFilters # ["open","cancelled"] "open" / "cancelled" / "pending_delivery" / "failed_delivery" / "successful"
    sortBy =  request.params.sortBy # "updatedAt"
    descending = request.params.descending   # "true" - if latest first or "false" - if oldest first

    
    # put constraint for getting expired requests
    currentDate = new Date()
    currentTimeStamp = currentDate.getTime()
    expiryValueInHrs = 24
    queryDate = new Date()
    time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000)
    queryDate.setTime(time24HoursAgo)    

    if requestType is "expired" 
        queryRequest = new Parse.Query("Request")

        innerQueryCustomer = new Parse.Query(Parse.User)
        innerQueryCustomer.equalTo("objectId", customerId)
        queryRequest.matchesQuery("customerId", innerQueryCustomer)

        if productId isnt ""
            innerQueryProduct = new Parse.Query("ProductItem")
            innerQueryProduct.equalTo("objectId", productId)
            queryRequest.matchesQuery("product", innerQueryProduct)

        queryRequest.equalTo("status", "open")

        queryRequest.lessThanOrEqualTo( "createdAt", queryDate )  

    else if requestType is "nonexpired"
        queryNonExpiredOpenReq = new Parse.Query("Request")

        innerQueryCustomer = new Parse.Query(Parse.User)
        innerQueryCustomer.equalTo("objectId", customerId)
        queryNonExpiredOpenReq.matchesQuery("customerId", innerQueryCustomer)

        if productId isnt ""
            innerQueryProduct = new Parse.Query("ProductItem")
            innerQueryProduct.equalTo("objectId", productId)
            queryNonExpiredOpenReq.matchesQuery("product", innerQueryProduct)

        queryNonExpiredOpenReq.equalTo("status","open")
        queryNonExpiredOpenReq.greaterThanOrEqualTo( "createdAt", queryDate )

        #########################################################################


        if selectedFilters.length is 0
            otherRequestStatuses = ["cancelled","pending_delivery","failed_delivery", "sent_for_delivery", "successful"]
        else
            otherRequestStatuses = _.without(selectedFilters, "open")
        

        queryOtherStatusReq = new Parse.Query("Request") 

        innerQueryCustomer2 = new Parse.Query(Parse.User)
        innerQueryCustomer2.equalTo("objectId", customerId)
        queryOtherStatusReq.matchesQuery("customerId", innerQueryCustomer2)

        if productId isnt ""
            innerQueryProduct2 = new Parse.Query("ProductItem")
            innerQueryProduct2.equalTo("objectId", productId)
            queryOtherStatusReq.matchesQuery("product", innerQueryProduct2)        
        
        queryOtherStatusReq.containedIn("status", otherRequestStatuses) 

        if (_.indexOf(selectedFilters, "open") > -1) or (selectedFilters.length is 0)
            queryRequest = Parse.Query.or(queryNonExpiredOpenReq, queryOtherStatusReq)  
        else
            queryRequest = queryOtherStatusReq     

    else if requestType is "all"
        queryRequest = new Parse.Query("Request")

        innerQueryCustomer = new Parse.Query(Parse.User)
        innerQueryCustomer.equalTo("objectId", customerId)
        queryRequest.matchesQuery("customerId", innerQueryCustomer)

        if productId isnt ""
            innerQueryProduct = new Parse.Query("ProductItem")
            innerQueryProduct.equalTo("objectId", productId)
            queryRequest.matchesQuery("product", innerQueryProduct)         

    queryRequest.include("product") 

    if descending is true
        queryRequest.descending("updatedAt")
    else
        queryRequest.ascending("updatedAt")        
    
    # pagination
    queryRequest.limit(displayLimit)
    queryRequest.skip(page * displayLimit)     
    

    queryRequest.find()
    .then (requests) ->

        productPricesQs = _.map(requests, (reqObj) ->
            getRequestsWithPrice(reqObj)
        )

        Parse.Promise.when(productPricesQs).then -> 
            pastRequests = _.flatten(_.toArray(arguments))               
            response.success pastRequests
        , (error) ->
            response.error error

    , (error) ->
        response.error error    

Parse.Cloud.define 'getSingleRequest' , (request, response) ->
    requestId = request.params.requestId
    
    sellerDetails = 
        "id" : request.params.sellerId
        "geoPoint" : request.params.sellerGeoPoint

    queryRequest = new Parse.Query("Request")
    queryRequest.equalTo("objectId", requestId)

    # queryRequest.select("address,addressGeoPoint,category,brand,product,comments,customerId,status")

    queryRequest.include("product")
    queryRequest.include("category")
    queryRequest.include("category.parent_category")
    queryRequest.include("brand")    

    queryRequest.first()
    .then (requestObject) ->
        productLastOfferedPrices = {}
        # find all requests for which seller has made offer
        innerQuerySellers = new Parse.Query(Parse.User)
        innerQuerySellers.equalTo("objectId" , sellerDetails["id"] )

        offerQuery = new Parse.Query("Offer")
        offerQuery.matchesQuery("seller",innerQuerySellers)

        # offerQuery.select("request")
        offerQuery.include("request")
        offerQuery.include("request.product")
        offerQuery.include("request.category")
        offerQuery.include("request.category.parent_category")
        offerQuery.include("price")
        offerQuery.descending("createdAt")

        offerQuery.find()
        .then (offersMadeBySeller) ->

            productLastOfferedPrices = {}
            requestsWhereOfferMade = []
            productLastOfferedDeliveryTime = {}

            # all offers made by seller
            _.each offersMadeBySeller , (offerMadeBySeller) ->
                requestObj = offerMadeBySeller.get("request")
                productObj = requestObj.get("product")
                productId = productObj.id 
                priceObj =  offerMadeBySeller.get("price")
                offerPrice =  priceObj.get("value")

                productLastOfferedPrices[productId] = offerPrice
                
                lastDeliveryTime = offerMadeBySeller.get("deliveryTime")
                productLastOfferedDeliveryTime[productId] = lastDeliveryTime 

            lastOffers = []          
            lastOffers[0] =  productLastOfferedPrices         
            lastOffers[1] =  productLastOfferedDeliveryTime                

            getRequestData(requestObject,sellerDetails,lastOffers)

            .then (requestData) ->
                response.success requestData
            , (error) ->
                response.error error
        , (error) ->
            response.error error

    , (error) ->
        response.error error

Parse.Cloud.define 'getOpenRequestCount' , (request, response) -> 
    customerId = request.params.customerId

    # find all request for the customer
    innerQueryCustomer = new Parse.Query(Parse.User)
    innerQueryCustomer.equalTo("objectId" , customerId)

    queryRequests = new Parse.Query("Request")
    queryRequests.matchesQuery("customerId" , innerQueryCustomer)
    queryRequests.equalTo("status" , "open")

    # get only non expired requests
    currentDate = new Date()
    currentTimeStamp = currentDate.getTime()
    expiryValueInHrs = 24
    queryDate = new Date()
    time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000)
    queryDate.setTime(time24HoursAgo)

    queryRequests.greaterThanOrEqualTo( "createdAt", queryDate ) 
               
    queryRequests.find()
    .then (requestObjects) ->
        requestCount = requestObjects.length
        offerCount = 0



        if requestCount is 0 
            offerCount = 0
        else
             _.each requestObjects , (requestObject) ->
                offerCount += requestObject.get("offerCount")

        result = 
            "requestCount" : requestCount
            "offerCount" : offerCount

        response.success result


    , (error) ->
        response.error error

# API to get request details based on request id or offer id (used in customer app for single request details)
Parse.Cloud.define 'getRequestDetails', (request, response) ->
    offerId = request.params.offerId
    requestId = request.params.requestId

    if !_.isEmpty offerId
        queryOffer = new Parse.Query("Offer")
        queryOffer.equalTo("objectId", offerId)
        queryOffer.select("request")
        queryOffer.include("request")
        queryOffer.include("request.product")
        queryOffer.first()
        .then (offerObj) ->
            requestObj = offerObj.get("request")
            productObj = requestObj.get("product")  
            getOtherPricesForProduct(productObj)
            .then (otherPrice) ->
                product = 
                    "name" :productObj.get("name")
                    "images" :productObj.get("images")
                    "mrp" :productObj.get("mrp")
                    "onlinePrice" : otherPrice["online"]["value"]
                    "platformPrice" : otherPrice["platform"]["value"]
                


                requestResult = 
                    "id" : requestObj.id
                    "product" : product
                    "status" : requestObj.get("status")
                    "address" : requestObj.get("address")
                    "comments" : requestObj.get("comments")
                    "createdAt" : requestObj.createdAt
                    "updatedAt" : requestObj.updatedAt
                    "offerCount" : requestObj.get("offerCount")

                response.success requestResult 
                           
            , (error) ->
                response.error error 
        , (error) ->
            response.error error                   

    else if !_.isEmpty requestId
        # query request directly
        queryRequest = new Parse.Query("Request")
        queryRequest.equalTo("objectId", requestId)
        queryRequest.include("product")
        queryRequest.first()
        .then (requestObj) ->
            productObj = requestObj.get("product")  
            getOtherPricesForProduct(productObj)
            .then (otherPrice) ->
                product = 
                    "name" :productObj.get("name")
                    "images" :productObj.get("images")
                    "mrp" :productObj.get("mrp")
                    "onlinePrice" : otherPrice["online"]["value"]
                    "platformPrice" : otherPrice["platform"]["value"]
                


                requestResult = 
                    "id" : requestObj.id
                    "product" : product
                    "status" : requestObj.get("status")
                    "address" : requestObj.get("address")
                    "comments" : requestObj.get("comments")
                    "createdAt" : requestObj.createdAt
                    "updatedAt" : requestObj.updatedAt
                    "offerCount" : requestObj.get("offerCount")

                response.success requestResult  
            
            , (error) ->
                response.error error            

        , (error) ->
            response.error error


getNewRequestsForSeller = (sellerId,requestFilters) ->
    promise = new Parse.Promise()

    city = requestFilters["city"]
    area = requestFilters["area"]
    sellerLocation = requestFilters["sellerLocation"]
    sellerRadius = requestFilters["sellerRadius"]
    categories = requestFilters["categories"]
    brands = requestFilters["brands"]
    productMrp = requestFilters["productMrp"]

    status = "open"

    # find categories and brands supported by the seller
    sellerQuery = new Parse.Query(Parse.User)
    sellerQuery.equalTo("objectId", sellerId)
    sellerQuery.include("supportedCategories")
    sellerQuery.include("supportedBrands")

    sellerQuery.first()
    .then (sellerObject) ->

        Category = Parse.Object.extend("Category")
        Brand = Parse.Object.extend("Brand")

        supportedCategories = sellerObject.get("supportedCategories")
        supportedBrands = sellerObject.get("supportedBrands")

        filterCategories = []
        _.each supportedCategories , (supportedCategory) ->
            cat =
                "id" : supportedCategory.id
                "name" : supportedCategory.get("name")
            filterCategories.push cat

        filterBrands = []
        _.each supportedBrands , (supportedBrand) ->
            brand =
                "id" : supportedBrand.id
                "name" : supportedBrand.get("name")
            filterBrands.push brand            

        if categories is "default"
            sellerCategories = supportedCategories
        else
            sellerCategories = []
            _.each categories, (categoryId ) ->
                catPointer = new Category()
                catPointer.id = categoryId

                sellerCategories.push catPointer
        

        if brands is "default"
            sellerBrands = supportedBrands
        else
            sellerBrands = []
            _.each brands, (brandId) ->
                brandPointer = new Brand()
                brandPointer.id = brandId

                sellerBrands.push brandPointer 

        if city is 'default'
            city = sellerObject.get("city")

        if area is 'default'
            area = sellerObject.get("area")

        if  sellerLocation is 'default'
            sellerLocation =  sellerObject.get("addressGeoPoint")
        else
            sellerLocation =  sellerLocation

        if sellerRadius is 'default'
            sellerRadius = sellerObject.get("deliveryRadius")
        else
            sellerRadius = parseInt sellerRadius

      
        # find all requests for which seller has made offer
        innerQuerySellers = new Parse.Query(Parse.User)
        innerQuerySellers.equalTo("objectId" , sellerId )

        offerQuery = new Parse.Query("Offer")
        offerQuery.matchesQuery("seller",innerQuerySellers)

        # offerQuery.select("request")
        offerQuery.include("request")
        offerQuery.include("request.product")
        offerQuery.include("price")
        offerQuery.descending("createdAt")

        offerQuery.find()
        .then (offersMadeBySeller) ->

            productLastOfferedPrices = {}
            productLastOfferedDeliveryTime = {}
            requestsWhereOfferMade = []

            # all offers made by seller
            _.each offersMadeBySeller , (offerMadeBySeller) ->
                requestObj = offerMadeBySeller.get("request")
                productObj = requestObj.get("product")
                productId = productObj.id 
                priceObj =  offerMadeBySeller.get("price")
                offerPrice =  priceObj.get("value")

                productLastOfferedPrices[productId] = offerPrice

                lastDeliveryTime = offerMadeBySeller.get("deliveryTime")
                productLastOfferedDeliveryTime[productId] = lastDeliveryTime
                
                requestsWhereOfferMade.push offerMadeBySeller.get("request").id

            # requestsWhereOfferMade = _.map(offersMadeBySeller , (offerMade) ->
                
            #     offerMade.get("request").id

            # ) 

            lastOffers = []          
            lastOffers[0] =  productLastOfferedPrices         
            lastOffers[1] =  productLastOfferedDeliveryTime         

            requestQuery = new Parse.Query("Request")
            requestQuery.containedIn("category",sellerCategories)
            requestQuery.containedIn("brand",sellerBrands)

            ## remove city/area constraint for new requests
            # requestQuery.equalTo("city",city)
            # requestQuery.equalTo("area",area)
            requestQuery.equalTo("status",status)


            # get only non expired requests
            currentDate = new Date()
            currentTimeStamp = currentDate.getTime()
            expiryValueInHrs = 24
            queryDate = new Date()
            time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000)
            queryDate.setTime(time24HoursAgo)

            requestQuery.greaterThanOrEqualTo( "createdAt", queryDate )

            # requests within catchment area
            sellerGeoPoint = new Parse.GeoPoint sellerLocation
            requestQuery.withinKilometers("addressGeoPoint", sellerGeoPoint, sellerRadius)

            requestQuery.notContainedIn("objectId", requestsWhereOfferMade)

            # requestQuery.select("address,addressGeoPoint,category,brand,product,comments,customerId,offerCount,status")
            if productMrp isnt "default"
                startPrice = parseFloat productMrp[0]
                endPrice = parseFloat productMrp[1]
                innerQueryProduct = new Parse.Query("ProductItem")

                if startPrice is -1
                    innerQueryProduct.lessThanOrEqualTo("mrp", endPrice)
                else if endPrice is -1
                    innerQueryProduct.greaterThanOrEqualTo("mrp", startPrice)
                else
                    innerQueryProduct.lessThanOrEqualTo("mrp", endPrice)
                    innerQueryProduct.greaterThanOrEqualTo("mrp", startPrice)
                
                requestQuery.matchesQuery("product", innerQueryProduct)

            requestQuery.include("product")
            requestQuery.include("category")
            requestQuery.include("category.parent_category")
            requestQuery.include("brand")

            # @todo exclude requests if offer is already made

            requestQuery.find()
            .then (filteredRequests) ->

                # Product name
                # mrp
                # parent category name
                # sub category name
                # brand name

                requestsQs = []
                sellerDetails = 
                    "id" : sellerId 
                    "geoPoint" : sellerGeoPoint

                requestsQs = _.map(filteredRequests , (filteredRequest) ->
                    requestPromise = getRequestData(filteredRequest,sellerDetails,lastOffers)
                )   

                Parse.Promise.when(requestsQs).then ->
                    individualReqResults = _.flatten(_.toArray(arguments)) 
                    imageSizes = getImageSizes("product")
                    requestsResult = 
                        "city" : city
                        "area" : area
                        "radius" : sellerRadius
                        "location" : sellerLocation
                        "requests" : individualReqResults
                        "sellerCategories" : filterCategories
                        "sellerBrands" : filterBrands
                        "imageSizes" : imageSizes

                    promise.resolve requestsResult

            , (error) ->
                promise.reject error

        , (error) ->
            promise.reject error
    , (error) ->
        promise.reject error 

    promise           

getRequestData =  (filteredRequest,seller,lastOffers ) ->
    
    promise = new Parse.Promise()

    productLastOfferedPrices = lastOffers[0]
    productLastOfferedDeliveryTime = lastOffers[1] 
    
    sellerId = seller.id 
    sellerGeoPoint = seller.geoPoint

    # prepare the output without notification status
    prodObj = filteredRequest.get("product")
    
    productId = prodObj.id
    product =
        "id": prodObj.id
        "name":prodObj.get("name")
        "mrp":prodObj.get("mrp")
        "image":prodObj.get("images")
        "model_number":prodObj.get("model_number")

    # returns object of online price and best platfomr price
    getOtherPricesForProduct(prodObj)
    .then (productPrice) ->
        categoryObj = filteredRequest.get("category")
        category =
            "id" : categoryObj.id
            "name": categoryObj.get("name")
            "parent": (categoryObj.get("parent_category")).get("name")

        brandObj = filteredRequest.get("brand")
        brand =
            "id" : brandObj.id
            "name": brandObj.get("name")  

        reuqestGeoPoint =  filteredRequest.get("addressGeoPoint")  
        radiusDiffInKm =   reuqestGeoPoint.kilometersTo(sellerGeoPoint) 

        productsWithLastOffered = _.keys(productLastOfferedPrices)

        if _.indexOf(productsWithLastOffered, productId) > -1
            lastOffered = productLastOfferedPrices[productId]
        else
            lastOffered = ""

         
        productsWithLastOfferedDelivery = _.keys(productLastOfferedDeliveryTime)   
        if _.indexOf(productsWithLastOfferedDelivery, productId) > -1
            lastOfferedDeliveryTime = productLastOfferedDeliveryTime[productId]
        else
            lastOfferedDeliveryTime = ""


        imageSizes = getImageSizes("product")    
        requestObj = 
            id : filteredRequest.id
            radius : radiusDiffInKm
            product: product
            category: category
            brand: brand
            createdAt: filteredRequest.createdAt
            comments: filteredRequest.get("comments")  
            status: filteredRequest.get("status")            
            offerCount: filteredRequest.get("offerCount")  
            lastOfferPrice : lastOffered
            lastDeliveryTime : lastOfferedDeliveryTime
            onlinePrice: productPrice["online"]["value"] 
            platformPrice : productPrice["platform"]["value"]     
            imageSizes : imageSizes    

        
        #  now query notification to get notificaton status
        queryNotification = new Parse.Query("Notification")

        innerQuerySeller = new Parse.Query(Parse.User)
        innerQuerySeller.equalTo("objectId",sellerId )

        queryNotification.matchesQuery("recipientUser",innerQuerySeller)
        
        queryNotification.equalTo("type","Request")

        innerQueryRequest = new Parse.Query("Request")
        innerQueryRequest.equalTo("objectId", filteredRequest.id)

        queryNotification.matchesQuery("requestObject",innerQueryRequest)

        queryNotification.first()
        .then (notificationObject) ->

            if !_.isEmpty(notificationObject)
                notification = 
                    "hasSeen" : notificationObject.get("hasSeen")

                requestObj['notification'] = notification

                promise.resolve requestObj

            else
                Notification = Parse.Object.extend("Notification")
                notificationInstance = new Notification()

                sellerObj = 
                    "__type" : "Pointer",
                    "className":"_User",
                    "objectId":sellerId 
                
                notificationInstance.set "channel" , "push_copy"
                notificationInstance.set "type" , "Request"
                notificationInstance.set "processed" , true
                notificationInstance.set "requestObject" , filteredRequest
                notificationInstance.set "recipientUser" , sellerObj
                notificationInstance.set "hasSeen" , false

                notificationInstance.save()
                .then (savedNotification) ->
                    notification = 
                        "hasSeen" : savedNotification.get("hasSeen")

                    requestObj['notification'] = notification

                    promise.resolve requestObj  

        , (error) ->
            promise.reject error

    , (error) ->
        promise.reject error 

    promise

getRequestsWithPrice = (requestObj) ->
    promise = new Parse.Promise()

    currentDate = new Date()
    createdDate = requestObj.createdAt
    diff = currentDate.getTime() - createdDate.getTime()
    differenceInDays =  Math.floor(diff / (1000 * 60 * 60 * 24)) 

    # if expired
    requestStatus = requestObj.get("status")
    
    if differenceInDays >= 1 
        if requestStatus is "open"
            requestStatus = "expired"

    productObj = requestObj.get("product")

    getOtherPricesForProduct(productObj)
    .then (otherPrice) ->
        
        product =
            "name": productObj.get("name")
            "images": productObj.get("images")
            "mrp": productObj.get("mrp")
            "onlinePrice" : otherPrice["online"]["value"]
            "platformPrice" : otherPrice["platform"]["value"]

        
        pastReq = 
            "id" : requestObj.id
            "product" : product
            "status" : requestStatus
            "createdAt": requestObj.createdAt
            "updatedAt": requestObj.updatedAt
            "differenceInDays" :differenceInDays
            "address": requestObj.get("address")
            "comments": requestObj.get("comments")
            "offerCount": requestObj.get("offerCount")

        pastReq

        promise.resolve pastReq

    , (error) ->
        promise.reject error 

    promise

