angular.module 'LocalHyper.auth'


.factory 'AuthAPI', ['$q', 'App', '$http', '$rootScope', 'User', ($q, App, $http, $rootScope, User)->

	UUID = App.deviceUUID()
	AuthAPI = {}

	AuthAPI.getAESKey = (phone)->
		key = phone.split("").reverse().join "#*!$@"
		key

	AuthAPI.encryptPassword = (password, phone)->
		key = @getAESKey phone
		encrypted = CryptoJS.AES.encrypt password, key
		encrypted.toString()

	AuthAPI.decryptPassword = (passwordHash, phone)->
		key = @getAESKey phone
		decrypted = CryptoJS.AES.decrypt passwordHash, key
		decrypted.toString CryptoJS.enc.Utf8

	AuthAPI.isExistingUser = (user)->
		defer = $q.defer()
		phone = user.phone.toString()

		user = new Parse.Query Parse.User
		user.equalTo "username", phone
		user.find()
		.then (userObj)=>
			data = {}
			if _.isEmpty userObj
				data.existing = false
			else
				data.existing = true
				data.userObj = userObj
			defer.resolve data

		, (error)=>
			@onParseJsError defer, error

		defer.promise

	AuthAPI.register = (user)->
		defer = $q.defer()

		@isExistingUser user
		.then (data)=>
			if !data.existing then @signUpNewUser()
			else @loginExistingUser(data.userObj)
		.then (success)->
			defer.resolve success
		, (error)=>
			@onParseJsError defer, error

		defer.promise

	AuthAPI.getUserDetails = ->
		user = User.info 'get'

		data = 
			phone: user.phone
			displayName: user.name

		data

	AuthAPI.loginExistingUser = (userObj)->
		defer = $q.defer()
		info = @getUserDetails()
		phone = info.phone
		newPassword = ''
		userObj = userObj[0]
		oldPasswordhash = userObj.get 'passwordHash'
		oldPassword = @decryptPassword oldPasswordhash, phone

		Parse.User.logOut()
		.then ->
			Parse.User.logIn phone, oldPassword
		.then (user)=>
			newPassword = "#{phone}#{UUID}"
			newPasswordHash = @encryptPassword newPassword, phone
			App.getInstallationId().then (installationId)->
				user.save
					"displayName": info.displayName
					"password": newPassword
					"passwordHash": newPasswordHash
					"installationId": installationId
					"lastLogin": new Date()
		.then ->
			Parse.User.logOut()
		.then ->
			Parse.User.logIn phone, newPassword
		.then (success)->
			defer.resolve success
		, (error)=>
			@onParseJsError defer, error

		defer.promise

	AuthAPI.signUpNewUser = (phone, name)->
		defer = $q.defer()
		info = @getUserDetails()
		phone = info.phone
		password = "#{phone}#{UUID}"

		App.getInstallationId()
		.then (installationId)=>
			user = new Parse.User()
			user.set 
				"userType": "customer"
				"username": phone
				"displayName": info.displayName
				"password": password
				"passwordHash": @encryptPassword(password, phone)
				"installationId": installationId
				"lastLogin": new Date()
			
			user.signUp()
		.then (success)->
			defer.resolve success
		, (error)=>
			@onParseJsError defer, error

		defer.promise

	AuthAPI.onParseJsError = (defer, error)->
		#Handle Parse JS SDK Error
		switch error.code
			when Parse.Error.CONNECTION_FAILED
				defer.reject 'server_error'
			when Parse.Error.INVALID_SESSION_TOKEN
				$rootScope.$broadcast 'on:session:expiry'
				defer.reject 'session_expired'
			else
				console.log 'Error code: '+error.code
				defer.reject 'unknown_error'

	AuthAPI
]

