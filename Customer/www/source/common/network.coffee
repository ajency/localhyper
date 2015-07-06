angular.module 'LocalHyper.common'


.factory 'Network', ['$q', '$cordovaNetwork', '$rootScope', 'User'
	, ($q, $cordovaNetwork, $rootScope, User)->

		Network = {}

		isHttpUrl = (url)->
			if s.contains(url, '.html') then false else true

		Network.request = (config)->
			url = config.url
			if isHttpUrl url
				if $rootScope.App.isOnline()
					config.url = "https://api.parse.com/1/#{url}"
					if User.isLoggedIn()
						config.headers['X-Parse-Session-Token'] = User.getSessionToken()
					config
				else $q.reject 'offline'
			else config

		Network.responseError = (rejection)->
			#Reasons for response failure
			#1) offline
			#2) server_error
			#3) session_expired
			if _.has rejection, 'data'
				if _.isNull rejection.data
					rejection = 'server_error'
				else if rejection.data.code is Parse.Error.INVALID_SESSION_TOKEN
					rejection = "session_expired"

			$q.reject rejection

		Network
]


.config ['$httpProvider', ($httpProvider)->
	
	$httpProvider.defaults.headers.post['Content-Type'] = 'application/json'
	$httpProvider.defaults.headers.common['X-Parse-Application-Id'] = APP_ID
	$httpProvider.defaults.headers.common['X-Parse-REST-API-Key']   = REST_API_KEY

	$httpProvider.interceptors.push 'Network'
]
