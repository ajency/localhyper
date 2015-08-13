
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

    makeOfferCredits = 1
    acceptOfferCredits = 5

    # make an entry in price class
    Price = Parse.Object.extend("Price")
    Offer = Parse.Object.extend("Offer")
    Request = Parse.Object.extend("Request")
    Notification = Parse.Object.extend("Notification") 

    # get request and get the product id associated to it
    requestQuery = new Parse.Query("Request")
    requestQuery.equalTo("objectId",requestId )

    requestQuery.first()
    .then (requestObject) ->
        requestingCustomer = requestObject.get("customerId")

        createdDateOfReq = requestObject.createdAt

        requestGeoPoint = requestObject.get("addressGeoPoint")

        price = new Price()

        price.set "source" , "seller"
        
        sellerObj = new Parse.User()
        sellerObj.id = sellerId

        price.set "seller" , sellerObj

        price.set "type" , "open_offer"
        
        price.set "value" , priceValue

        product = requestObject.get("product")
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
            offer.set "requestDate", requestObject.createdAt #needed for sorting offers based on created date of requests  
            offer.set "offerPrice", priceValue #needed for sorting by price
            offer.set "requestGeoPoint", requestObject.get("addressGeoPoint") #needed for sorting by distance

            offer.save()
            .then (offerObj) ->

                # make a transaction for the offer i.e deducted at the  time of making offer
                Transaction = Parse.Object.extend("Transaction")
                transaction = new Transaction()
                transaction.set "seller" , sellerObj
                transaction.set "transactionType" , "minus"
                transaction.set "creditCount" , makeOfferCredits
                transaction.set "towards" , "make_offer"
                transaction.set "offer" , offerObj

                transaction.save()
                .then (savedTransaction) ->
                    # on successful transaction

                    # update seller creditBalance
                    sellerObj.fetch()
                    .then (sellerFetchedObj) ->

                        sellersCurrentSubtractedCredit = sellerFetchedObj.get("subtractedCredit")
                        newSubtractedCredit = sellersCurrentSubtractedCredit + savedTransaction.get("creditCount")
                        sellerObj.set "subtractedCredit" , newSubtractedCredit 

                        sellerFetchedObj.save()
                        .then (updatedSellerCredit) ->

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

            , (error) ->
                response.error error

        , (error) ->
            response.error error

    , (error) ->
        response.error error


# API for offer history for sellers
Parse.Cloud.define 'getSellerOffers' , (request, response) ->
    sellerId = request.params.sellerId
    sellerGeoPoint = request.params.sellerGeoPoint
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit    
    acceptedOffers = request.params.acceptedOffers

    selectedFilters = request.params.selectedFilters # ["open","unaccepted"] or ["pending_delivery","sent_for_delivery", "failed_delivery", "successful"]
    sortBy =  request.params.sortBy # "updatedAt"
    descending = request.params.descending   # "true" - if latest first or "false" - if oldest first    

    innerSellerQuery = new Parse.Query(Parse.User)
    innerSellerQuery.equalTo("objectId",sellerId)  

    # find out if atleast one request is made for a given product id and customer id
    queryOffers = new Parse.Query("Offer")
    queryOffers.matchesQuery("seller", innerSellerQuery)
    
    if acceptedOffers is true
        allowedStatuses = ["accepted"]
        if selectedFilters.length is 0
            allowedReqStatuses = ["pending_delivery","sent_for_delivery", "failed_delivery", "successful"] 
        else
            allowedReqStatuses = selectedFilters 
            
        innerQueryRequest = new Parse.Query("Request")
        innerQueryRequest.containedIn("status", allowedReqStatuses)
        queryOffers.matchesQuery("request", innerQueryRequest)
        queryOffers.containedIn("status", allowedStatuses)

    else
        if selectedFilters.length is 0
            allowedStatuses = ["open", "unaccepted"]  
        else
            allowedStatuses = _.without(selectedFilters, "expired")
    
        queryOffers.containedIn("status", allowedStatuses)

    # pagination
    queryOffers.limit(displayLimit)
    queryOffers.skip(page * displayLimit)  

    
    if sortBy is "distance"
        queryOffers.near("requestGeoPoint", sellerGeoPoint)  

    else
        if sortBy is "offerPrice"
            sortColumn = "offerPrice"
        else if sortBy is "expiryTime"
            sortColumn = "requestDate"
        else if sortBy is "updatedAt"
            sortColumn = "updatedAt"
        else if sortBy is "deliveryDate"
            sortColumn = "deliveryDate"
        else
            sortColumn = "updatedAt"

        if descending is true
            queryOffers.descending(sortColumn)
        else
            queryOffers.ascending(sortColumn)  

    queryOffers.include("price")  
    queryOffers.include("request")  
    queryOffers.include("seller")  
    queryOffers.include("price")  
    queryOffers.include("request.product")  
    queryOffers.include("request.brand")  
    queryOffers.include("request.category")  
    queryOffers.include("request.category.parent_category")  

    queryOffers.find()

    .then (offers) ->
        sellerOffers = []
        _.each offers, (offerObj) ->

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
                "modelNumber" : productObj.get("model_number")
                "images" : productObj.get("images")

            brand = 
                "objectId" : brandObj.id 
                "name" : brandObj.get("name") 

            category = 
                "objectId" : categoryObj.id 
                "name" : categoryObj.get("name")
                "parentCategory" : categoryObj.get("parent_category").get("name")

            sellerGeoPoint = sellerObj.get("addressGeoPoint")
            requestGeoPoint =  requestObj.get("addressGeoPoint")  
            sellersDistancFromCustomer =   requestGeoPoint.kilometersTo(sellerGeoPoint)  

            currentDate = new Date()
            createdDate = requestObj.createdAt
            diff = currentDate.getTime() - createdDate.getTime()
            differenceInDays =  Math.floor(diff / (1000 * 60 * 60 * 24)) 

            # if expired
            requestStatus = requestObj.get("status")
            
            if differenceInDays >= 1 
                if requestStatus is "open"
                    requestStatus = "expired"                                

            failedDeliveryReason = requestObj.get("failedDeliveryReason")
            if _.isNull(failedDeliveryReason)
                failedDeliveryReason = ""

            request = 
                "id" : requestObj.id
                "address" : requestObj.get("address")
                "status" : requestStatus
                "differenceInDays" :differenceInDays
                "offerCount" : requestObj.get("offerCount")
                "comments" : requestObj.get("comments")
                "failedDeliveryReason" : failedDeliveryReason
                "createdAt" : requestObj.createdAt  

            sellerOffer = 
                "id" : offerObj.id
                "product" : product
                "brand" : brand
                "category" : category
                "request" : request
                "distanceFromCustomer" : sellersDistancFromCustomer
                "offerPrice" : priceObj.get("value")   
                "offerStatus" : offerObj.get("status")   
                "offerDeliveryTime" : offerObj.get("deliveryTime")   
                "offerDeliveryDate" : offerObj.get("deliveryDate")   
                "offerDeliveryDate" : offerObj.get("deliveryDate")   
                "offerComments" : offerObj.get("comments")   
                "createdAt" : offerObj.createdAt  
                "updatedAt" : offerObj.updatedAt  
                
            
            sellerOffers.push sellerOffer                

        response.success sellerOffers
    , (error) ->
        response.error error  
    


Parse.Cloud.afterSave "Offer", (request)->
    offerObject = request.object

    if !offerObject.existed()
        requestId = offerObject.get("request").id
      
        RequestClass = Parse.Object.extend("Request")
        queryReq = new Parse.Query(RequestClass)
      
        queryReq.get(requestId)
        .then (requestObj) ->
            requestObj.increment("offerCount")
            requestObj.save()
        ,(error) ->
            console.log "Got an error " + error.code + " : " + error.message
  

Parse.Cloud.define 'getRequestOffers' , (request, response) ->
    requestId = request.params.requestId

    # get all offers for the request
    queryOffers = new Parse.Query("Offer")
    innerQueryRequest = new Parse.Query("Request")
    innerQueryRequest.equalTo("objectId",requestId)
    queryOffers.matchesQuery("request",innerQueryRequest)
    
    queryOffers.include("price")
    queryOffers.include("request")
    queryOffers.include("request.product")
    queryOffers.include("seller")

    queryOffers.find()
    .then (offerObjects) ->
        offers = []      
        offers = _.map(offerObjects , (offerObject) ->

                    productObj = offerObject.get("request").get("product")

                    product = 
                        "name" : productObj.get("name")
                        "images" : productObj.get("images")


                    sellerObj = offerObject.get("seller")

                    seller =
                        "displayName" : sellerObj.get("displayName")
                        "businessName" : sellerObj.get("businessName")
                        "address" : sellerObj.get("address")
                        "city" : sellerObj.get("city")
                        "phoneNumber" : sellerObj.get("username")

                    priceObj = offerObject.get("price")

                    if !_.isUndefined offerObject.get("deliveryDate")
                        deliveryDate = offerObject.get("deliveryDate")
                    else 
                        deliveryDate = ""
                    
                    offer = 
                        "id" : offerObject.id
                        "product" : product
                        "seller" : seller
                        "price" : priceObj.get("value")
                        "comments" : offerObject.get("comments")
                        "deliveryTime" : offerObject.get("deliveryTime")
                        "status" : offerObject.get("status")
                        "createdAt" : offerObject.createdAt
                        "updatedAt" : offerObject.updatedAt
                        "deliveryDate" : deliveryDate

                    offer    

                )

        response.success offers 

    , (error) ->
        response.error error


Parse.Cloud.define 'acceptOffer', (request, response) ->
    offerId = request.params.offerId
    unacceptedOfferIds = request.params.unacceptedOfferIds

    acceptOfferCredits = 5
    
    Offer = Parse.Object.extend('Offer')

    offersToBeUpdated = []

    acceptedOffer = 
        "id" : offerId
        "status" : "accepted"

    offersToBeUpdated.push acceptedOffer

    if unacceptedOfferIds.length > 0
        _.each unacceptedOfferIds , (unacceptedOfferId) ->
            unacceptedOffer = 
                "id" : unacceptedOfferId
                "status" : "unaccepted"

            offersToBeUpdated.push unacceptedOffer

    offerSavedArr = []
    _.each offersToBeUpdated, (offerObj) -> 
        offer = new Offer()

        offer.id = offerObj.id        
        offer.set "status" , offerObj.status

        offerSavedArr.push(offer) 

    # save all the newly created objects
    Parse.Object.saveAll offerSavedArr
    .then (savedOfferObjs) ->
        queryOffer = new Parse.Query("Offer")
        queryOffer.equalTo("objectId" , offerId )
        queryOffer.include("request")
        queryOffer.include("seller")

        queryOffer.first()
        .then (acceptedOffer)->            
            sellerObj = acceptedOffer.get "seller"
            # make a transaction for the offer i.e deducted at the  time of making offer
            Transaction = Parse.Object.extend("Transaction")
            transaction = new Transaction()
            transaction.set "seller" , sellerObj
            transaction.set "transactionType" , "minus"
            transaction.set "creditCount" , acceptOfferCredits
            transaction.set "towards" , "accept_offer"
            transaction.set "offer" , acceptedOffer

            transaction.save()
            .then (savedTransaction) ->
                
                sellersCurrentSubtractedCredit = sellerObj.get("subtractedCredit")
                newSubtractedCredit = sellersCurrentSubtractedCredit + savedTransaction.get("creditCount")
                sellerObj.set "subtractedCredit" , newSubtractedCredit 

                sellerObj.save() 
                .then (updatedSellerCredit) ->
                    requestObj = acceptedOffer.get "request"

                    # @todo save delivery date correctly
                    claimedDelivery = acceptedOffer.get "deliveryTime"
                    deliveryDuration = parseInt claimedDelivery.value

                    offerAcceptedDate = acceptedOffer.updatedAt

                    sellerOffDays = ["Sunday","Monday"]

                    sellerWorkTimings  = ["9:00:00", "18:00:00"]

                    # deliveryDate = getDeliveryDate(claimedDelivery,offerAcceptedDate,sellerOffDays,sellerWorkTimings)
                    deliveryDate = moment(offerAcceptedDate).add(deliveryDuration , "hours").toDate()

                    acceptedOffer.set("deliveryDate",deliveryDate)
                    acceptedOffer.save()
                    .then (offerWithDelivery) ->
                        requestObj.set "status" , "pending_delivery"
                        requestObj.save()
                        .then (savedReq)->
                            # make entry in notification class
                            # create entry in notification class with recipient as the seller
                            notificationData = 
                                hasSeen: false
                                recipientUser: sellerObj
                                channel : 'push'
                                processed : false
                                type : "AcceptedOffer"
                                offerObject : acceptedOffer

                            Notification = Parse.Object.extend("Notification") 
                            notification = new Notification notificationData
                            notification.save()
                            .then (notifObj) ->
                                resultObj =
                                    offerId : acceptedOffer.id 
                                    offerStatus : acceptedOffer.get("status")
                                    offerUpdatedAt : acceptedOffer.updatedAt
                                    requestId : acceptedOffer.get("request").id
                                    requestStatus : acceptedOffer.get("request").get("status")
                                response.success resultObj    
                            , (error) ->
                                response.error error 
                        , (error) ->
                            response.error error 
                    , (error) ->
                        response.error error
                , (error) ->
                    response.error error
            , (error) ->
                response.error error
        , (error) ->
            response.error error                               
    , (error) ->
        response.error "Failed to update offer status due to - #{error.message}" 



Parse.Cloud.define 'getRequestForOffer', (request, response) ->
    offerId = request.params.offerId

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
            
            if !_.isUndefined offerObj.get("deliveryDate")
                deliveryDate = offerObj.get("deliveryDate")
            else 
                deliveryDate = ""

            requestResult = 
                "id" : requestObj.id
                "product" : product
                "status" : requestObj.get("status")
                "address" : requestObj.get("address")
                "comments" : requestObj.get("comments")
                "createdAt" : requestObj.createdAt
                "updatedAt" : requestObj.updatedAt
                "offerCount" : requestObj.get("offerCount")
                "deliveryDate" : deliveryDate

            response.success requestResult 
                       
        , (error) ->
            response.error error    


    , (error) ->
        response.error error

# check if offer notification has been seen or not
Parse.Cloud.define 'isOfferNotificationSeen', (request, response) ->
    userId = request.params.userId
    requestId = request.params.requestId

    type = "Offer"

    # find first offer for that request
    # query offer and get request associated to it
    queryOffer = new Parse.Query("Offer")

    innerQueryRequest = new Parse.Query("Request")
    innerQueryRequest.equalTo("objectId",requestId)
    queryOffer.matchesQuery("request", innerQueryRequest)

    queryOffer.first()
    .then (offerObj) ->
        if _.isEmpty(offerObj)
            hasSeen = true
            result =
                "requestId" : requestId
                "offerId" : ""
                "hasSeen" : hasSeen
            response.success result
        else
            offerId = offerObj.id

            queryNotification = new Parse.Query("Notification")
            queryNotification.equalTo("type", "Offer" )

            innerQueryOffer = new Parse.Query("Offer")
            innerQueryOffer.equalTo("objectId",offerId)

            queryNotification.matchesQuery("offerObject",innerQueryOffer)

            innerUserQuery = new Parse.Query(Parse.User)
            innerUserQuery.equalTo("objectId",userId)

            queryNotification.matchesQuery("recipientUser",innerUserQuery) 


            queryNotification.first()
            .then (notificationObj) ->
                hasSeen = notificationObj.get("hasSeen") 
                
                result =
                    "requestId" : requestId
                    "offerId" : offerId
                    "hasSeen" : hasSeen
                
                response.success result                      

            , (error) ->
                response.error "1"+error

    , (error) ->
        response.error "2"+error

Parse.Cloud.define 'getAcceptedOfferCount', (request, response) ->
    sellerId = request.params.sellerId

    # find all offers made by seller id with status "accepted"
    queryOffers = new Parse.Query("Offer")

    innerQuerySeller = new Parse.Query(Parse.User)
    innerQuerySeller.equalTo("objectId", sellerId)

    queryOffers.matchesQuery("seller",innerQuerySeller)
    queryOffers.equalTo("status","accepted")

    queryOffers.count()
    .then (count)->
        response.success count
    , (error) ->
        response.error error



Parse.Cloud.define 'testDeliveryDate', (request, response) ->   
    
    claimedDelivery = request.params.claimedDelivery
    offerAcceptedDate = request.params.offerAcceptedDate
    sellerOffDays = request.params.sellerOffDays
    sellerWorkTimings = request.params.sellerWorkTimings

    deliveryDates = getDeliveryDate(claimedDelivery,offerAcceptedDate,sellerOffDays,sellerWorkTimings)
    offerAcceptedDate2 = deliveryDates["offerAcceptedDate"]
    deliveryDate = deliveryDates["deliveryDate"]
    adjustedDeliveryDate = deliveryDates["adjustedDeliveryDate"]

    endWorkTime = sellerWorkTimings[1]
    timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
    
    pendingHours = getHoursDifference(endWorkTime, timeOfDelivery)

    result = 
        moment : moment()
        deliveryDate : moment(deliveryDate).format('dddd DD-MM-YYYY HH:mm:ss')
        adjustedDeliveryDate : moment(adjustedDeliveryDate).format('dddd DD-MM-YYYY HH:mm:ss')
        acceptedDate : moment(offerAcceptedDate).format('dddd DD-MM-YYYY HH:mm:ss')
        offerAcceptedDate2 : deliveryDates["offerAcceptedDate"]
        isDayValidWorking : isValidWorkDay(deliveryDate,sellerOffDays)
        isDayValidWorkTime : isValidWorkTime(deliveryDate,sellerWorkTimings)
        addedDateObject : moment(incrementDateObject(deliveryDate)).format('dddd DD-MM-YYYY HH:mm:ss')
        isTimeBeforeWorkTime : isTimeBeforeWorkTime(deliveryDate,sellerWorkTimings)
        pendingHours : pendingHours
        timeOfDelivery : timeOfDelivery
        endtime : sellerWorkTimings[1]
    response.success result

getDeliveryDate = (claimedDelivery,offerAcceptedDate,sellerOffDays,sellerWorkTimings) ->

    deliveryDuration = claimedDelivery.value
    deliveryUnit = claimedDelivery.unit

    if deliveryUnit is "day"
        deliveryDuration = deliveryDuration * 24
    
    deliveryDate = moment(offerAcceptedDate).add('hours',deliveryDuration).toDate()


    pendingHours = ""


   
    adjustedDeliveryDate = fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings,deliveryDuration)

    obj = 
        offerAcceptedDate : offerAcceptedDate
        deliveryDate : deliveryDate
        adjustedDeliveryDate :adjustedDeliveryDate

    return obj

fetchAdjustedDelivery = (offerAcceptedDate, deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration) ->
    # deliveryTime = moment().hour(startTime[0]).minute(startTime[1]).seconds(startTime[2]).add(deliveryDuration, 'hours').format("HH:mm:ss");
    if isValidWorkDay(deliveryDate ,sellerOffDays)
        if _.isEmpty(pendingHours)
            if isValidWorkTime(deliveryDate, sellerWorkTimings)
                console.log "step1"
                
                if(isTimeBeforeWorkTime(offerAcceptedDate, sellerWorkTimings))
                    console.log "step2"
                    startTime = sellerWorkTimings[0]
                    startTime = startTime.split(':')

                    startWorkTime = 
                        "hours" : parseInt startTime[0]
                        "minutes" : parseInt startTime[1]
                        "seconds" : parseInt startTime[2]


                    dDate = deliveryDate
                    acceptDate = offerAcceptedDate
                    modifiedAcceptedDate = moment(acceptDate).hours(startWorkTime["hours"]).minutes(startWorkTime["minutes"]).seconds(startWorkTime["seconds"]).toDate()
                    deliveryDate =  moment(modifiedAcceptedDate).add('hours',deliveryDuration).toDate()
                    fetchAdjustedDelivery(modifiedAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
                # if accepted date's time is less than start time of seller then delivery date's time = start_time + deliveryDuration
                # set time of deliveryDate as startWork time
                # to it add deliveryDuration then run the function again
                else
                    console.log "step3"
                    deliveryDate
            else
                console.log "step4"
                if(isTimeBeforeWorkTime(deliveryDate, sellerWorkTimings))
                    console.log "step5"
                    pendingHours = deliveryDuration
                    fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
                    
                else
                    console.log "step6"
                    # get difference from delivery date's time and end time of work time
                    endWorkTime = sellerWorkTimings[1]
                    timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
                    pendingHours = getHoursDifference(endWorkTime,timeOfDelivery)     # timeOfDelivery > endWorkTime

                    console.log "pending hours#{pendingHours}"

                    deliveryDate = incrementDateObject(deliveryDate)

                    fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)

        else 
            console.log "step7"
            # deliveryDate + startTime + pendingHours
            startWorkTime = sellerWorkTimings[0]
            timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
            diffInStartAndDelivery = getHoursDifference(timeOfDelivery,startWorkTime)  # startWorkTime > timeOfDelivery

            diffHours = moment(diffInStartAndDelivery, "hh:mm:ss").hours()
            diffMin = moment(diffInStartAndDelivery, "hh:mm:ss").minutes()
            diffSec = moment(diffInStartAndDelivery, "hh:mm:ss").seconds()

            dDate = deliveryDate
            
            moment(dDate).add('hours',diffHours)
            moment(dDate).add('minutes',diffMin)
            finalMoment = moment(dDate).add('seconds',diffSec)

            deliveryDate = finalMoment.toDate()

    else
        console.log "step8"
        deliveryDate = incrementDateObject(deliveryDate)
        deliveryDate = fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings,deliveryDuration)


getHoursDifference = (initialTimeString, finalTimeString) ->
    t1 = moment(initialTimeString, "hh:mm:ss")
    t2 = moment(finalTimeString, "hh:mm:ss")
    t3 = moment(t2.diff(t1)).format("hh:mm:ss")  

    return t3 

     
isTimeInRange = (time, range)->
    time = time.split(':')
    timeHour = parseInt time[0]
    timeMin = parseInt time[1]

    startTime = range[0].split(':')
    startTimeHour = parseInt startTime[0]
    startTimeMin = parseInt startTime[1]

    endTime = range[1].split(':')
    endTimeHour = parseInt endTime[0]    
    endTimeMin = parseInt endTime[1]    
    
    if timeHour > startTimeHour and timeHour < endTimeHour
      return true
    else if timeHour is startTimeHour and timeHour < endTimeHour
        if timeMin >= startTimeMin
            return true
        else 
            return false
    else if timeHour > startTimeHour and timeHour is endTimeHour
        if timeMin <= endTimeMin
            return true
        else 
            return false        
    else
      return false


isValidWorkDay = (dateObj,nonWorkDays) ->
    day = moment(dateObj).format('dddd')

    if _.indexOf(nonWorkDays,day) > -1 
        return false 
    else
        return true
 
isValidWorkTime = (dateObj,workTimings) ->

    time = moment(dateObj).format('HH:mm:ss')

    isTimeInRange(time,workTimings)
   

incrementDateObject = (dateObj) ->
    incrementedDateObj = moment(dateObj).add('days',1).toDate()
    return incrementedDateObj

isTimeBeforeWorkTime = (dateObj , workTimings) ->
    time = moment(dateObj).format('HH:mm:ss')
    time = time.split(':')
    timeHour = parseInt time[0]

    startTime = workTimings[0].split(':')
    startTimeHour = parseInt startTime

    endTime = workTimings[1].split(':')
    endTimeHour = parseInt endTime    
    
    if timeHour < startTimeHour 
        obj =
            startTimeHour : startTimeHour
            timeHour : timeHour
        return true
    else
        return false 