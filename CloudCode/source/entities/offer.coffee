# get new offers for a customer for a product
Parse.Cloud.define 'getNewOffers', (request, response) ->
    
    productId = request.params.productId
    customerId  = request.params.customerId

    innerProductQuery = new Parse.Query("ProductItem")
    innerProductQuery.equalTo("objectId",productId)

    innerCustomerQuery = new Parse.Query(Parse.User)
    innerCustomerQuery.equalTo("objectId",customerId)  

    # find out if atleast one request is made for a given product id and customer id
    queryReq = new Parse.Query("Request")
    queryReq.matchesQuery("product", innerProductQuery)
    queryReq.matchesQuery("customerId", innerCustomerQuery)

    queryReq.first()
    .then (requestObj) ->
        if _.isEmpty(requestObj) 
            moreRequests = false
            result = 
                "activeRequest" : {}
                "offers": []
                "moreRequests" : moreRequests 

            response.success result            
        else
            moreRequests = true
            
            # get expired requests for this customer and product
            queryRequest = new Parse.Query("Request")

            # get requests based on customerId and productId 
            queryRequest.matchesQuery("product", innerProductQuery)
            queryRequest.matchesQuery("customerId", innerCustomerQuery)

            # get only non expired requests
            currentDate = new Date()
            currentTimeStamp = currentDate.getTime()
            expiryValueInHrs = 24
            queryDate = new Date()
            time24HoursAgo = currentTimeStamp - (expiryValueInHrs * 60 * 60 * 1000)
            queryDate.setTime(time24HoursAgo)

            queryRequest.greaterThanOrEqualTo( "createdAt", queryDate )    

            # get the most recent non expired request, i.e sort with new ones first
            queryRequest.descending("createdAt")

            
            queryRequest.find()
            .then (allNonExpiredRequests) ->

                if allNonExpiredRequests.length is 0
                    result = 
                        "activeRequest" : {}
                        "offers": []
                        "moreRequests" : moreRequests

                    response.success result

                else 
                    mostRecentRequest = allNonExpiredRequests[0]

                    recentRequestStatus = mostRecentRequest.get "status"

                    if recentRequestStatus is "open"
                        # get open offers for the request

                        queryOffer = new Parse.Query("Offer")

                        innerRequestQuery = new Parse.Query("Request")
                        innerRequestQuery.equalTo("objectId",mostRecentRequest.id)
                        queryOffer.matchesQuery("request", innerRequestQuery)

                        queryOffer.equalTo("status","open")

                        queryOffer.find()
                        .then (offers) ->
                            result = 
                                "activeRequest" : mostRecentRequest
                                "offers": offers
                                "moreRequests" : moreRequests

                            response.success result 

                        , (error) ->
                            response.error error

                    else
                        result = 
                            "activeRequest" : {}
                            "offers": []
                            "moreRequests" : moreRequests

                        response.success result 
            , (error) ->
                response.error error 



    , (error) ->
        response.error error

  
        


# make offer for a seller
Parse.Cloud.define 'makeOffer', (request, response) ->  

    requestId = request.params.requestId
    sellerId = request.params.sellerId
    priceValue = parseInt request.params.priceValue
    deliveryTime = request.params.deliveryTime
    comments = request.params.comments
    status = request.params.status

    # make an entry in price class
    Price = Parse.Object.extend("Price")
    Offer = Parse.Object.extend("Offer")
    Request = Parse.Object.extend("Request")
    Notification = Parse.Object.extend("Notification") 

    # get request and get the product id associated to it
    requestQuery = new Parse.Query("Request")
    requestQuery.equalTo("objectId",requestId )

    requestQuery.first()
    .then (requestObj) ->
        requestingCustomer = requestObj.get("customerId")

        price = new Price()

        price.set "source" , "seller"
        
        sellerObj = new Parse.User()
        sellerObj.id = sellerId

        price.set "seller" , sellerObj

        price.set "type" , "open_offer"
        
        price.set "value" , priceValue

        product = requestObj.get("product")
        price.set "product" , product

        price.save()
        .then (priceObj) ->
            # make an entry in offer class
            offer = new Offer()

            requestObj = new Request()
            requestObj.id = requestId

            offer.set "seller" , sellerObj
            offer.set "request", requestObj 
            offer.set "price", priceObj 
            offer.set "status" , status
            offer.set "deliveryTime" , deliveryTime
            offer.set "comments" , comments

            offer.save()
            .then (offerObj) ->

                notification = new Notification()

                notification.set "hasSeen" , false
                notification.set "recipientUser" , requestingCustomer
                notification.set "channel" , "push"
                notification.set "processed" , false
                notification.set "type" , "Offer"
                notification.set "offerObject" , offerObj
                
                notification.save()
                .then (notificationObj) ->
                    response.success(notificationObj)
                
                , (error) ->
                    response.error error

            , (error) ->
                response.error error

        , (error) ->
            response.error error

    , (error) ->
        response.error error



Parse.Cloud.define 'getSellerOffers' , (request, response) ->
    sellerId = request.params.sellerId
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit    

    innerSellerQuery = new Parse.Query(Parse.User)
    innerSellerQuery.equalTo("objectId",sellerId)  

    # find out if atleast one request is made for a given product id and customer id
    queryOffers = new Parse.Query("Offer")
    queryOffers.matchesQuery("seller", innerSellerQuery)

    # pagination
    queryOffers.limit(displayLimit)
    queryOffers.skip(page * displayLimit)  

    queryOffers.include("price")  
    queryOffers.include("request")  
    queryOffers.include("seller")  
    queryOffers.include("price")  
    queryOffers.include("request.product")  
    queryOffers.include("request.brand")  
    queryOffers.include("request.category")  

    queryOffers.find()

    .then (offers) ->
        sellerOffers = _.map(offers, (offerObj) ->

            requestObj = offerObj.get("request")           
            productObj = requestObj.get("product")
            brandObj = requestObj.get("brand")
            categoryObj = requestObj.get("category")
            sellerObj = offerObj.get("seller")
            priceObj = offerObj.get("price")

            product = 
                "objectId" : productObj.id
                "name" : productObj.get("name")
                "mrp" : productObj.get("mrp")

            brand = 
                "objectId" : brandObj.id 
                "name" : brandObj.get("name") 

            category = 
                "objectId" : categoryObj.id 
                "name" : categoryObj.get("name")

            sellerGeoPoint = sellerObj.get("addressGeoPoint")
            requestGeoPoint =  requestObj.get("addressGeoPoint")  
            sellersDistancFromCustomer =   reuqestGeoPoint.kilometersTo(sellerGeoPoint)                    

           
            sellerOffer = 
                "product" : product
                "brand" : brand
                "category" : category
                "address" : requestObj.get("address")
                "distance" : sellerGeoPoint
                "distance" : sellersDistancFromCustomer
                "distance" : requestGeoPoint
                "offerPrice" : priceObj.get("value")   
                "offerStatus" : offerObj.get("status")   


            sellerOffer
        )

        response.success sellerOffers
    , (error) ->
        response.error error  
    