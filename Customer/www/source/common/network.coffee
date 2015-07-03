angular.module 'LocalHyper.common'


.factory 'Network', ['$q', '$cordovaNetwork', ($q, $cordovaNetwork)->

	Network = {}

	isOnline = ->
		if ionis.Platform.isWebView() then $cordovaNetwork.isOnline()
		else navigator.onLine

	isHttpUrl = (config)->
		if s.contains(config.url, '.html') then false else true

	Network.request = (config)->
		if isHttpUrl config
			if isOnline() then config
			else $q.reject 'offline'
		else config

	Network.responseError = (rejection)->
		# if rejection is 'offline'
		$q.reject rejection

	Network
]


.config ['$httpProvider', ($httpProvider)->

	contentType = 'application/x-www-form-urlencoded; charset=UTF-8'
	$httpProvider.defaults.headers.common['Content-Type'] = contentType
	$httpProvider.defaults.headers.post['Content-Type']   = contentType

	$httpProvider.interceptors.push 'Network'
]