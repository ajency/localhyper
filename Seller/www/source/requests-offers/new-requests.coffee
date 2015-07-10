angular.module 'LocalHyper.requestsOffers'


.controller 'NewRequestCtrl', ['$scope', 'App', ($scope, App)->


	$scope.$on '$ionicView.afterEnter', ->
		App.hideSplashScreen()
]