angular.module 'LocalHyper.auth'


.factory 'AuthAPI', ['$q', 'App', ($q, App)->

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

	AuthAPI.isExistingUser = (phone)->
		defer = $q.defer()
		userQuery = new Parse.Query Parse.User
		userQuery.equalTo "username", phone

		userQuery.find()
		.then (userObj)->
			existing = if _.isEmpty(userObj) then false else true
			defer.resolve existing
		, (error)->
			defer.reject error

		defer.promise

	AuthAPI.register = (user)->
		defer = $q.defer()
		phone = user.phone.toString()
		name  = user.name

		onSuccess = (success)->
			defer.resolve success

		onError = (error)->
			defer.reject error

		@isExistingUser phone
		.then (exists)=>
			if exists
				@loginExistingUser(phone, name).then onSuccess, onError
			else
				@signUpNewUser(phone, name).then onSuccess, onError

		, onError

		defer.promise

	AuthAPI.loginExistingUser = (phone, name)->
		defer = $q.defer()

		onError = (error)->
			defer.reject error

		updateUser = (user)=>
			password = "#{phone}#{UUID}"
			passwordHash = @encryptPassword password, phone
			
			user.set "displayName", name
			user.set "password", password
			user.set "passwordHash", passwordHash
			user.save()
			.then (success)->
				defer.resolve success
			, onError

		userQuery = new Parse.Query Parse.User
		userQuery.equalTo "username", phone

		userQuery.find()
		.then (userObj)=>
			passwordHash = userObj[0].get 'passwordHash'
			password = @decryptPassword passwordHash, phone
			Parse.User.logOut()
			.then ->
				Parse.User.logIn phone, password
				.then updateUser, onError
			, onError
		, onError

		defer.promise

	AuthAPI.signUpNewUser = (phone, name)->
		defer = $q.defer()
		password = "#{phone}#{UUID}"

		user = new Parse.User()
		user.set "username", phone
		user.set "displayName", name
		user.set "password", password

		passwordHash = @encryptPassword password, phone
		user.set "passwordHash", passwordHash
		user.signUp()
		.then (success)->
			defer.resolve success
		, (error)->
			defer.reject error

		defer.promise

	AuthAPI
]

