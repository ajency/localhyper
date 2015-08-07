Parse.Cloud.define 'getCreditBalance' , (request, response) ->
    sellerId = request.params.sellerId

    creditValueForSingleAdd = 100    
    creditValueForSingleMakeOffer = 1    
    creditValueForSingleAcceptOffer = 5 

    innerQuerySeller = new Parse.Query(Parse.User)
    innerQuerySeller.equalTo("objectId" , sellerId)    

    queryAddTransaction = new Parse.Query("Transaction")
    queryAddTransaction.matchesQuery("seller",innerQuerySeller)
    queryAddTransaction.equalTo("transactionType","add")

    queryAddTransaction.count()
    .then (addCount) ->
        countOfAddTransactions  = addCount

        queryMinusMakeOfferTransaction = new Parse.Query("Transaction")
        queryMinusMakeOfferTransaction.matchesQuery("seller",innerQuerySeller)
        queryMinusMakeOfferTransaction.equalTo("transactionType","minus") 
        queryMinusMakeOfferTransaction.equalTo("towards","make_offer") 

        queryMinusMakeOfferTransaction.count()
        .then (minusMakeOfferCount) ->
            countMakeOfferTransactions = minusMakeOfferCount

            queryMinusAcceptOfferTransaction = new Parse.Query("Transaction")
            queryMinusAcceptOfferTransaction.matchesQuery("seller",innerQuerySeller)
            queryMinusAcceptOfferTransaction.equalTo("transactionType","minus") 
            queryMinusAcceptOfferTransaction.equalTo("towards","make_offer") 

            queryMinusMakeOfferTransaction.count()
            .then (minusAcceptOfferCount) ->
               countAcceptOfferTransactions = minusAcceptOfferCount

               totalAddCredits = creditValueForSingleAdd * countOfAddTransactions
               totalMinusCredits = (creditValueForSingleMakeOffer * countMakeOfferTransactions) + (creditValueForSingleAcceptOffer * minusAcceptOfferCount)

               balance = totalAddCredits - totalMinusCredits

               result =
                    totalCredits : totalAddCredits
                    usedCredits : totalMinusCredits
                    balanceCredits : balance

               response.success result 

            , (error) ->
                response.error error

        , (error) ->
            response.error error

    , (error) ->
        response.error error

Parse.Cloud.define 'getCreditHistory' , (request, response) ->  
    sellerId = request.params.sellerId
    displayLimit =  request.params.displayLimit     
    page =  request.params.page     

    innerQuerySeller = new Parse.Query(Parse.User)
    innerQuerySeller.equalTo("objectId",sellerId)

    queryTransaction = new Parse.Query("Transaction")
    queryTransaction.matchesQuery("seller" , innerQuerySeller)

    queryTransaction.descending("createdAt")
    queryTransaction.include("offer")
    queryTransaction.include("offer.request")
    queryTransaction.include("offer.request.product")
    

    # pagination
    queryTransaction.limit(displayLimit)
    queryTransaction.skip(page * displayLimit)

    queryTransaction.find()
    .then (transactions) ->
        if transactions.length is 0
            response.success transactions
        else
            result = []
            _.each transactions , (transaction) ->

                if !_.isUndefined(transaction.get("offer"))
                    offerObj = transaction.get("offer")
                    requestObj = offerObj.get("request")
                    productObj = requestObj.get("product")
                

                    offer = 
                        "id" : offerObj.id 
                        "status" : offerObj.get("status") 
                        "createdAt" : offerObj.createdAt
                        "updatedAt" : offerObj.updatedAt

                    product = 
                        "name" : productObj.get("name")
                        "model_number" : productObj.get("model_number")
                else 
                    offer = {}
                    product = {}


                if _.isUndefined(transaction.get("towards"))
                    towards = ""
                else
                    towards = transaction.get("towards")
                    
                transactionResult = 
                    "id" : transaction.id 
                    "createdAt" : transaction.createdAt
                    "transactionType" : transaction.get("transactionType")
                    "transactionTowards" : towards
                    "creditCount" : transaction.get("creditCount")
                    "offer" : offer
                    "product" : product

                result.push transactionResult

            response.success result

    , (error) ->
        response.error error


            
