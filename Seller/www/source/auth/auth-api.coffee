angular.module 'LocalHyper.auth'


.factory 'AuthAPI', ['$q', 'App', '$http', '$rootScope', ($q, App, $http, $rootScope)->

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

	AuthAPI.register = (user)->
		defer = $q.defer()
		phone = user.phone.toString()
		name  = user.name

		user = new Parse.Query Parse.User
		user.equalTo "username", phone
		user.find()
		.then (userObj)=>
			if _.isEmpty(userObj) then @signUpNewUser(phone, name)
			else @loginExistingUser(phone, name, userObj)
		.then (success)->
			defer.resolve success
		, (error)=>
			@onParseJsError defer, error

		defer.promise

	AuthAPI.loginExistingUser = (phone, name, userObj)->
		defer = $q.defer()
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
					"displayName": name
					"password": newPassword
					"passwordHash": newPasswordHash
					"installationId": installationId
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
		password = "#{phone}#{UUID}"

		App.getInstallationId()
		.then (installationId)=>
			user = new Parse.User()
			user.set 
				"username": phone
				"displayName": name
				"password": password
				"installationId": installationId
				"userType": "seller"
				"passwordHash": @encryptPassword(password, phone)
			
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

