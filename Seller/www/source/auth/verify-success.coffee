angular.module 'LocalHyper.auth'


.controller 'VerifySuccessCtrl', ['$scope', 'CToast', 'App'
	, 'CSpinner', 'User', '$ionicPlatform', '$rootScope', 'Storage'
	, ($scope, CToast, App, CSpinner, User, $ionicPlatform, $rootScope, Storage)->

		$scope.onProceed = ->
			Storage.bussinessDetails 'remove'
			Storage.categoryChains 'remove'
			App.navigate 'new-requests', {}, {animate: true, back: false}

			

		$scope.$on '$ionicView.enter', ->
		$ionicPlatform.onHardwareBackButton $scope.onProceed

		$scope.$on '$ionicView.leave', ->
		$ionicPlatform.offHardwareBackButton $scope.onProceed
]
