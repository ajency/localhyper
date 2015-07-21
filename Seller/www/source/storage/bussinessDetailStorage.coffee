angular.module 'LocalHyper.BussinessDetailStorage', []


.factory 'BussinessDetailStorage', [->

	BussinessStorage = {}

	Storage.slideTutorial = (action)->
		switch action
			when 'set'
				localforage.setItem 'app_tutorial_seen', true
			when 'get'
				localforage.getItem 'app_tutorial_seen'

	BussinessStorage
]