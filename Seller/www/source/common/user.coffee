angular.module 'LocalHyper.common'


.factory 'User', [->

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

	User.info = (action, data={})->
		switch action
			when 'set'
				_.each data, (val, index)->
					userInfo[index] = val
			when 'get'
				userInfo
			when 'reset'
				userInfo = data


	User
]