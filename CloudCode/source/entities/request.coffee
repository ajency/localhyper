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

                    getAreaBoundSellers(sellerId,sellerGeoPoint,sellerRadius,createdRequestId)
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
        
    status = "open"

    # find categories and brands supported by the seller
    sellerQuery = new Parse.Query(Parse.User)
    sellerQuery.equalTo("objectId", sellerId)

    sellerQuery.first()
    .then (sellerObject) ->
        sellerCategories = sellerObject.get("supportedCategories")
        sellerBrands = sellerObject.get("supportedBrands")

        if city is 'default'
            city = sellerObject.get("city")

        if area is 'default'
            area = sellerObject.get("area")

        if  sellerLocation is 'default'
            sellerLocation =  sellerObject.get("addressGeoPoint")
        else
            sellerLocation =  request.params.sellerLocation

        if sellerRadius is 'default'
            sellerRadius = sellerObject.get("deliveryRadius")
        else
            sellerRadius = parseInt request.params.sellerRadius
        

        requestQuery = new Parse.Query("Request")
        requestQuery.containedIn("category",sellerCategories)
        requestQuery.containedIn("brand",sellerBrands)
        requestQuery.equalTo("city",city)
        requestQuery.equalTo("area",area)
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

        requestQuery.select("address,addressGeoPoint,category,brand,product,comments,customerId")

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

            requests = []
            _.each filteredRequests , (filteredRequest) ->
                prodObj = filteredRequest.get("product")
                product =
                    "id": prodObj.id
                    "name":prodObj.get("name")
                    "mrp":prodObj.get("mrp")
                    "image":prodObj.get("images")

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

                requestObj = 
                    id : filteredRequest.id
                    radius : radiusDiffInKm
                    product: product
                    category: category
                    brand: brand
                    createdAt: filteredRequest.createdAt
                    comments: filteredRequest.get("comments")  

                requests.push requestObj


            
            requestsResult = 
                "city" : city
                "area" : area
                "radius" : sellerRadius
                "location" : sellerLocation
                "requests" : requests

            response.success requestsResult   
        , (error) ->
            response.error (error)
    , (error) ->
        response.error (error)

Parse.Cloud.define 'updateRequestStatus' , (request, response) ->
    requestId = request.params.requestId
    status = request.params.status
    failedDeliveryReason = request.params.failedDeliveryReason

    validStatuses = ['pending_delivery','failed_delivery','successful','cancelled']
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
            otherRequestStatuses = ["cancelled","pending_delivery","failed_delivery","successful"]
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
        pastRequests = _.map(requests, (requestObj) ->

            currentDate = new Date()
            createdDate = requestObj.createdAt
            diff = currentDate.getTime() - createdDate.getTime()
            differenceInDays =  Math.floor(diff / (1000 * 60 * 60 * 24)) 

            # if expired
            requestStatus = requestObj.get("status")
            
            if differenceInDays >= 1 
                if requestStatus is "open"
                    requestStatus = "expired"
                
            product =
                "name": requestObj.get("product").get("name")
                "images": requestObj.get("product").get("images")
                "mrp": requestObj.get("product").get("mrp")

            
            
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


        )
        response.success pastRequests
    , (error) ->
        response.error error    









