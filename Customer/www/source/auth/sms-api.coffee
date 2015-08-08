angular.module 'LocalHyper.auth'


.factory 'SmsAPI', ['$q', '$http', ($q, $http)->

	SmsAPI = {}

	SmsAPI.requestSMSCode = (phone, displayName, userType)->
		defer = $q.defer()

		$http.post 'functions/sendSMSCode', 
			phone: phone
			displayName: displayName
			userType: userType
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	SmsAPI.verifySMSCode = (phone, code)->
		defer = $q.defer()

		$http.post 'functions/verifySMSCode', {phone: phone, code: code}
		.then (data)->
			defer.resolve data.data.result
		, (error)->
			defer.reject error

		defer.promise

	SmsAPI
]