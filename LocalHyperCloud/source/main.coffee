$q   = require 'cloud/lib/q.js'
_    = require 'underscore'

Parse.Cloud.useMasterKey()

# {"request":"one", "location": "Panjim", "price": "Rs 10000", "deliveryTime": "1 Day", "installationId": "2cc36140-8568-46d6-a88a-6451a978d968"}
# {"request":"one", "location": "Panjim", "price": "Rs 10000", "deliveryTime": "1 Day", "installationId": "9d2c434f-eed9-45b7-920b-563956e982b2"}

getPushData = (installationId, pushOptions)->
	defer = $q.defer()
	installationQuery = new Parse.Query Parse.Installation
	installationQuery.equalTo "installationId", installationId

	installationQuery.find()
	.then (installationObject)->
		if _.isEmpty(installationObject) then deviceType = 'unknown'
		else deviceType = installationObject[0].get 'deviceType'

		if deviceType.toLowerCase() is 'android'
			pushData = 
				header: pushOptions.title
				message: pushOptions.alert
				request: pushOptions.request
		else
			pushData = 
				title: pushOptions.title
				alert: pushOptions.alert
				request: pushOptions.request
				badge: 'Increment'

		defer.resolve pushData

	, (error)->
		defer.reject error
	
	defer.promise
	

Parse.Cloud.define "addOffers", (request, response)->

	location        = request.params.location.toString()
	price           = request.params.price.toString()
	deliveryTime    = request.params.deliveryTime.toString()
	installationId  = request.params.installationId.toString()
	req = request.params.request.toString()

	Offers = Parse.Object.extend "Offers"
	offers = new Offers()

	offers.set 
		'location': location
		'price': price
		'deliveryTime': deliveryTime
		'request': req

	offers.save()
	.then (obj)->
		pushQuery = new Parse.Query Parse.Installation
		pushQuery.equalTo "installationId", installationId

		pushOptions = 
			title: 'LocalHyper'
			alert: 'New offer available'
			request: obj.get 'request'

		getPushData installationId, pushOptions
		.then (pushData)->
			Parse.Push.send({where: pushQuery, data: pushData})
			.then ->
				response.success "SUCCESS: Saved new offer and sent push"
			, (error)->
				response.error "ERROR: Could not send push"

		, (error)->
			response.error 'ERROR: Could not get push data'

	, (object, error)->
		response.error "ERROR: Could not save offer"

