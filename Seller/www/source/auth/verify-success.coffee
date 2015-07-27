angular.module 'LocalHyper.auth'


.controller 'VerifySuccessCtrl', ['$scope', 'CToast', 'App'
	, 'CSpinner', 'User', '$ionicPlatform', '$rootScope', 'Storage'
	, ($scope, CToast, App, CSpinner, User, $ionicPlatform, $rootScope, Storage)->

		$scope.view = 
			onProceed : ->
				Storage.bussinessDetails 'remove'
				Storage.categoryChains 'remove'
				App.navigate 'new-requests', {}, {animate: true, back: false}
]
