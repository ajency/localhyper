Parse.Cloud.define 'createRequest' , (request, response) ->

    customerId = request.params.customerId
    productId = request.params.productId
    location = request.params.location	

    latitude = location.lat 
    longitude = location.long 
    addressText = location.text

    comments = request.params.comments
    deliveryStatus = request.params.deliveryStatus # 'open' initially

    