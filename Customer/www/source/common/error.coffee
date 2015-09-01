angular.module 'LocalHyper.common'


.directive 'ajError', [->

	restrict: 'E'
	replace: true
	templateUrl: 	'views/common/error.html'

	scope:
		tapToRetry: '&'
		errorType: '='
	
	link: (scope, el, attr)->
		
		switch scope.errorType
			when 'offline'
				errorMsg = 'No internet availability'
			when 'server_error'
				errorMsg = 'Could not connect to server'
			when 'session_expired'
				errorMsg = 'Your session has expired'
			else
				errorMsg = 'Unknown error'
		
		scope.errorMsg = errorMsg

		scope.onTryAgain = ->
			scope.tapToRetry()
]

