angular.module 'LocalHyper.auth'


.controller 'SignUpCtrl', ['$scope', 'AuthAPI', ($scope, AuthAPI)->

	$scope.signUp = 
		name: 'Deepak'
		phone: '9765436351'

	$scope.onSignUp = ->
		AuthAPI.register $scope.signUp
		.then (success)->
			console.log success
		, (error)->
			console.log error
]
