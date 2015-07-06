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

	User.info = (action, data={})->
		switch action
			when 'set'
				userInfo = 
					name: data.name
					phone: data.phone
			when 'get'
				userInfo

	User
]