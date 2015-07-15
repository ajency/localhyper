angular.module 'LocalHyper.common'


.factory 'User', ['$q', ($q)->

	User = {}
	userInfo = {}

	User.isLoggedIn = ->
		user = Parse.User.current()
		loggedIn = if _.isNull(user) then false else true
		loggedIn

	User.getSessionToken = ->
		user = Parse.User.current()
		user.getSessionToken()

	User.getCurrent = ->
		user = Parse.User.current()
		user

	User.getId = ->
		@getCurrent().id

	User.update = (params)->
		defer = $q.defer()

		@getCurrent().save params
		.then ->
			defer.resolve()
		, (error)->
			defer.reject error

		defer.promise

	User.info = (action, data={})->
		switch action
			when 'set'
				_.each data, (val, index)->
					userInfo[index] = val
			when 'get'
				userInfo

	User
]
