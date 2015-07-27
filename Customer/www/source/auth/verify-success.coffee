angular.module 'LocalHyper.auth'


.controller 'VerifySuccessCtrl', ['$scope', 'CToast', 'App', 'SmsAPI', 'AuthAPI'
	, 'CSpinner', 'User', '$ionicPlatform', '$rootScope', '$stateParams'
	, ($scope, CToast, App, SmsAPI, AuthAPI, CSpinner, User, $ionicPlatform, $rootScope, $stateParams)->

		$scope.view = 
			
			onNext : ->
				goBackPage = if App.previousState == 'verify-manual' then -4 else -3
				count = if App.isAndroid() then goBackPage else -3
				App.goBack count
						
		onDeviceBack = ->
			count = if App.isAndroid() then -2 else -1
			App.goBack count

		$scope.$on '$ionicView.beforeEnter', ->
			$scope.view.user = User.info 'get'

		$scope.$on '$ionicView.enter', ->
			#Device hardware back button for android
			$ionicPlatform.onHardwareBackButton onDeviceBack
			$scope.view.isExistingUser() if App.isIOS()

		$scope.$on '$ionicView.leave', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
]
