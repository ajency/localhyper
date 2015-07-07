Parse.Cloud.define 'createRequest' , (request, response) ->

    customerId = request.params.customerId
    productId = request.params.productId
    location = request.params.location  

    # latitude = location.lat 
    # longitude = location.long 

    # latlongPoint = 
    #     latitude: latitude
    #     longitude: longitude

    addressText = request.params.addressText 

    comments = request.params.comments
    
    status = request.params.status # 'open' initially
    deliveryStatus = request.params.deliveryStatus 

    Request = Parse.Object.extend('Request')

    request = new Request()

    # set address geo point
    point = new Parse.GeoPoint location

    request.set "addressGeoPoint", point
    request.set "addressText", addressText
    request.set "status", status
    request.set "deliveryStatus", deliveryStatus

    # set request's customerId
    customerObj = 
        "__type" : "Pointer",
        "className":"_User",
        "objectId":customerId

    request.set "customerId", customerObj 
    
    # set product
    productObj =
        "__type" : "Pointer",
        "className":"ProductItem",
        "objectId":productId                    

    request.set "productId", productObj  

    request.save()
        .then (requestObject)->
            response.success requestObject
        , (error)->
            response.error "Failed to create request due to - #{error.message}"

