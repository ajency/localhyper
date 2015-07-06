angular.module 'LocalHyper.auth'


.controller 'VerifyBeginCtrl', ['$scope', 'App', 'CToast', 'User'
	, ($scope, App, CToast, User)->

		$scope.user = 
			name: 'Deepak'
			phone: '9765436351'

			onProceed : ->
				if _.contains [@name, @phone], ''
					CToast.show 'Fill up all fields'
				else if _.isUndefined @phone
					CToast.show 'Enter valid phone number'
				else
					@nextStep()

			nextStep : ->
				if App.isOnline()
					User.info 'set', $scope.user
					state = if App.isAndroid() then 'verify-auto' else 'verify-manual'
					App.navigate state
				else
					CToast.show 'No internet availability'
]