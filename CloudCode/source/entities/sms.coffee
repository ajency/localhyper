$q   = require 'cloud/lib/q.js'

Parse.Cloud.useMasterKey()

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

