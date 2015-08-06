angular.module 'LocalHyper.auth'


.controller 'VerifySuccessCtrl', ['$scope', 'App', '$ionicPlatform', ($scope, App, $ionicPlatform)->
		
	$scope.onProceed = ->
		App.navigate 'new-requests', {}, {animate: true, back: false}
		

	$scope.$on '$ionicView.enter', ->
		$ionicPlatform.onHardwareBackButton $scope.onProceed

	$scope.$on '$ionicView.leave', ->
		$ionicPlatform.offHardwareBackButton $scope.onProceed
]
