angular.module 'LocalHyper.common'


.factory 'UIMsg', [->

	UIMsg = 
		noInternet : 'No internet available. Please check your network settings'
		serverError: 'Could not connect to server. Please check your network settings' 
		

	UIMsg
]