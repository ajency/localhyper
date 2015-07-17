# get new offers for a customer for a product
Parse.Cloud.define 'getNewOffers', (request, response) ->
    
    productId = request.params.productId
    customerId  = request.params.customerId

    # get expired requests for this customer and product
    queryRequest = new Parse.Query("Request")

    # find out if atleast one request is made for a given product id and customer id

    innerProductQuery = new Parse.Query("ProductItem")
    innerProductQuery.equalTo("objectId",productId)

    innerCustomerQuery = new Parse.Query(Parse.User)
    innerCustomerQuery.equalTo("objectId",customerId)    

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

                    response.success result 

                , (error) ->
                    response.error error

            else
                result = 
                    "activeRequest" : {}
                    "offers": []

                response.success result 
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

