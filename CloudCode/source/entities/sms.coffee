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
			obj.save
				'phone': phone
				'verificationCode': code
				'attempts': attempts
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
	#Send sms using Nexmo
	obj = request.object
	phone = obj.get 'phone'
	verificationCode = obj.get 'verificationCode'

	# Parse.Cloud.httpRequest 
	# 	url: 'https://rest.nexmo.com/sms/json'
	# 	params:
	# 		api_key: '343ea2a4'
	# 		api_secret: 'a682ae14'
	# 		from: 'ShopOye'
	# 		to: "91#{phone}"
	# 		text: "Welcome to ShopOye. Your one time verification code is #{verificationCode}"

	# .then (httpResponse)->
	# 	console.log "SMS Sent: #{phone}"
	# , (httpResponse)->
	# 	console.log "SMS Error"


Parse.Cloud.define "verifySMSCode", (request, response)->
	phone = request.params.phone
	code  = request.params.code
	query = new Parse.Query 'SMSVerify'
	query.equalTo "phone", phone

	query.find()
	.then (obj)->
		obj = obj[0]
		verificationCode = obj.get 'verificationCode'
		verified = if verificationCode is code then true else false
		obj.destroy() if verified
		response.success 'verified': verified
	, (error)->
		response.error error

