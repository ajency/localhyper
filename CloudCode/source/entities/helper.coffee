resetRequestOfferCount = (requestId) ->
    
    promise = new Parse.Promise()
    # get request 
    queryOffer = new Parse.Query("Offer")

    innerQueryRequest = new Parse.Query("Request")
    innerQueryRequest.equalTo("objectId" , requestId)

    queryOffer.matchesQuery("request",innerQueryRequest)

    queryOffer.count()
    .then (offerCount)->
        # update request's offer count with this value
        Request = Parse.Object.extend("Request")
        requestInstance = new Request()
        requestInstance.id = requestId

        requestInstance.set "offerCount" , offerCount
        requestInstance.save()
        .then (savedReq) ->
            promise.resolve savedReq
        , (error) ->
            promise.reject error 
    , (error) ->
        response.error error 
    
    promise     


Parse.Cloud.define 'updateRequestOfferCount' , (request, response) ->

    customerId = request.params.customerId
    
    queryRequest = new Parse.Query("Request")

    innerQueryCustomer = new Parse.Query(Parse.User)
    innerQueryCustomer.equalTo("objectId", customerId)
    queryRequest.matchesQuery("customerId", innerQueryCustomer)
    
    queryRequest.find()
    .then (customersRequests) ->

        requestsQs = []
        
        requestsQs = _.map(customersRequests , (customersRequest) ->
            resetRequestOfferCount(customersRequest.id)
        )   

        Parse.Promise.when(requestsQs).then ->
            individualReqResults = _.flatten(_.toArray(arguments)) 
            response.success individualReqResults
        , (error) ->
            response.error error

    , (error) ->
        response.error error 





