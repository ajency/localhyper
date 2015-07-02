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
	req 			= request.params.request.toString()

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


Parse.Cloud.define "sendSMSCode", (request, response)->
	phone = request.params.phone
	code  = (Math.floor(Math.random()*900000)+100000).toString()

	onError = (error)->
		response.error error

	save = (obj, attempts)->
		if attempts > 3
			response.success attemptsExceeded: true
		else
			obj.set 
				'phone': phone
				'verificationCode': code
				'attempts': attempts
			
			obj.save()
			.then ->
				response.success code: code, attemptsExceeded: false
			, onError

	query = new Parse.Query 'SMSVerify'
	query.equalTo "phone", phone
	query.find()
	.then (obj)->
		if _.isEmpty obj
			SMSVerify = Parse.Object.extend "SMSVerify"
			verify = new SMSVerify()
			save verify, 1
		else
			obj = obj[0]
			attempts = obj.get 'attempts'
			save obj, attempts+1
	, onError


Parse.Cloud.afterSave "SMSVerify", (request)->
	#Send sms using twilio
	obj = request.object
	phone = obj.get 'phone'
	verificationCode = obj.get 'verificationCode'

	Parse.Cloud.httpRequest 
		url: 'https://rest.nexmo.com/sms/json'
		params:
			api_key: '343ea2a4'
			api_secret: 'a682ae14'
			from: 'ShopOye'
			to: "91#{phone}"
			text: "Welcome to ShopOye. Your one time verification code is #{verificationCode}"

	.then (httpResponse)->
		console.log "SMS SUCCESS"
		console.log httpResponse.text
	, (httpResponse)->
		console.log "SMS ERROR"
		console.error 'Request failed with response code ' + httpResponse.status


Parse.Cloud.define "verifySMSCode", (request, response)->
	phone = request.params.phone
	code  = request.params.code
	query = new Parse.Query 'SMSVerify'
	query.equalTo "phone", phone

	query.find()
	.then (obj)->
		obj = obj[0]
		verificationCode = obj.get 'verificationCode'
		if verificationCode is code
			obj.destroy()
			response.success 'verified': true
		else 
			response.success 'verified': false
	, (error)->
		response.error error

