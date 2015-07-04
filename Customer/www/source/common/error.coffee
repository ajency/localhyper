angular.module 'LocalHyper.common'


.directive 'ajError', [->

	restrict: 'E'
	replace: true
	template: 	'<div>
					<h3>Error</h3>
					</br>
					<h5 class="gray">{{errorMsg}}</h5>

					<div class="padding">
						<button 
							class="button button-dark aj-btn"
							ng-click="onTryAgain()">
							Try again
						</button>
					</div>
				</div>'

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

