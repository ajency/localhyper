# get new offers for a customer for a product
Parse.Cloud.define 'getNewOffers', (request, response) ->
    
 #    # return requests made and all offers for a given customerId and productId

 #    customerId = request.params.customerId
 #    productId = request.params.productId

 #    # get request made by customer for a productId
	# queryRequest = new Parse.Query("Request")
        
 #    # query to get specific product
 #    innerQueryProduct = new Parse.Query("ProductItem")
 #    innerQueryProduct.equalTo("objectId",productId)
 #    queryRequest.matchesQuery("product", innerQuery)

 # make offer for a seller
Parse.Cloud.define 'makeOffer', (request, response) ->	

# get all offers for a seller (offer history)