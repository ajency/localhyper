angular.module 'LocalHyper.auth'


.factory 'SmsAPI', ['$q', 'App', ($q, App)->

	SmsAPI = {}

	SmsAPI.requestSMSCode = (phone)->
		defer = $q.defer()

		Parse.Cloud.run 'sendSMSCode', phone: phone
		.then (data)->
			defer.resolve data
		, (error)->
			defer.reject error

		defer.promise

	SmsAPI.verifySMSCode = (phone, code)->
		defer = $q.defer()

		Parse.Cloud.run 'verifySMSCode', {phone: phone, code: code}
		.then (data)->
			defer.resolve data
		, (error)->
			defer.reject error

		defer.promise

	SmsAPI
]