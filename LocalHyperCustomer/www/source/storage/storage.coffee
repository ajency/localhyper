angular.module 'LocalHyper.storage', []


.factory 'Storage', [->

	Storage = {}

	Storage.slideTutorial = (action)->
		switch action
			when 'set'
				localforage.setItem 'app_tutorial_seen', true
			when 'get'
				localforage.getItem 'app_tutorial_seen'

	Storage
]