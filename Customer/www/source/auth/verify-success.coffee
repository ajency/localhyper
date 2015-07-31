angular.module 'LocalHyper.auth'


.controller 'VerifySuccessCtrl', ['$scope', 'App', '$ionicPlatform', ($scope, App, $ionicPlatform)->

	$scope.goBack = ->
		forAndroid = if App.previousState is 'verify-manual' then -4 else -3
		forIOS     = -3
		count = if App.isAndroid() then forAndroid else forIOS
		App.goBack count
	
	
	$scope.$on '$ionicView.enter', ->
		$ionicPlatform.onHardwareBackButton $scope.goBack

	$scope.$on '$ionicView.leave', ->
		$ionicPlatform.offHardwareBackButton $scope.goBack
]
