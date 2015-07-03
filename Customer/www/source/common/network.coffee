angular.module 'LocalHyper.common'


.factory 'Network', ['$q', '$cordovaNetwork', ($q, $cordovaNetwork)->

	Network = {}

	isOnline = ->
		if ionis.Platform.isWebView() then $cordovaNetwork.isOnline()
		else navigator.onLine

	isValidUrl = (config)->
		if s.contains(config.url, '.html') then false else true

	Network.request = (config)->
		if isValidUrl config
			if isOnline() then config
			else $q.reject 'no-internet'
		else config

	Network
]


.config ['$httpProvider', ($httpProvider)->

	contentType = 'application/x-www-form-urlencoded; charset=UTF-8'
	$httpProvider.defaults.headers.common['Content-Type'] = contentType
	$httpProvider.defaults.headers.post['Content-Type']   = contentType

	$httpProvider.interceptors.push 'Network'
]