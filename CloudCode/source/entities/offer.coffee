# get new offers for a customer for a product
Parse.Cloud.define 'getNewOffers', (request, response) ->
    
    productId = request.params.productId
    customerId  = request.params.customerId

    # get expired requests for this customer and product
	queryRequest = new Parse.Query("Request")
        
 #    # query to get specific product
 #    innerQueryProduct = new Parse.Query("ProductItem")
 #    innerQueryProduct.equalTo("objectId",productId)
 #    queryRequest.matchesQuery("product", innerQuery)

 # make offer for a seller
Parse.Cloud.define 'makeOffer', (request, response) ->	

	requestId = request.params.requestId
	sellerId = request.params.sellerId
	priceValue = parseInt request.params.priceValue
	deliveryTime = parseInt request.params.deliveryTime
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

