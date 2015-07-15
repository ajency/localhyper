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

	requestId = request.params.requestId
	sellerId = request.params.sellerId
	price = parseInt request.params.price
	deliveryTime = request.params.deliveryTime
	comment = request.params.comment

	# make an entry in price class
	# Price = {
	# 	'objectId' : '',
	# 	'productId' : 'm5mj8bmOOp',
	# 	'src' : seller / snapdeal/flipkart 
	# 	'seller' : sellerObject // (if src is seller)
	# 	'price' : '69.99',
	# 	‘type’ : ‘offer’,  //accepted_offer/external_market_price
	# }

	# # entry in offer class 
	# Offer = {
	# 	'objectId': 'offerId1',
	# 	request: 'requestObject',
	# 	price: priceObject
	# }

	# make an entry in price class
	Price = Parse.Object.extend("Price")
	Offer = Parse.Object.extend("Offer")
	Request = Parse.Object.extend("Request")

	price = new Price()

	price.set "src" , "seller"
	price.set "type" , "offer"

	sellerObj = new Parse.User()
	sellerObj.id = sellerId

	price.set "seller" , sellerObj
	
	price.set "value" , price

	price.save()
	.then(priceObj)->
		# make an entry in offer class
		offer = new Offer()

		requestObj = new Request()
		requestObj.id = requestId

		offer.set "request", requestObj 
		offer.set "price", priceObj 

		offer.save()
		.then (offerObj) ->
			response.success(offerObj)
		, (error) ->
			response.error error

	, (error) ->
		response.error error

