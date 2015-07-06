angular.module 'LocalHyper.auth'


.factory 'AuthAPI', ['$q', 'App', '$http', ($q, App, $http)->

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

		$http.get 'users', where: "username": phone
		.then (data)=>
			userObj = data.data.results
			existingUser = if _.isEmpty(userObj) then false else true
			if existingUser then @loginExistingUser(phone, name)
			else @signUpNewUser(phone, name)
		.then (success)->
			defer.resolve success
		, (error)->
			defer.reject error

		defer.promise

	AuthAPI.loginExistingUser = (phone, name)->
		defer = $q.defer()
		oldPassword = oldPasswordhash = ''
		newPassword = newPasswordHash = ''

		$http.get 'users', where: "username": phone
		.then (data)=>
			userObj = data.data.results[0]
			oldPasswordhash = userObj.passwordHash
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
			if _.has(error, 'code')
				@onParseJsError defer, error
			else
				defer.reject error

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
				defer.reject 'session_expired'
			else
				console.log 'Error code: '+error.code
				defer.reject 'unknown_error'

	AuthAPI
]

