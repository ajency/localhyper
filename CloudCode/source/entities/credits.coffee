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