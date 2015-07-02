angular.module 'LocalHyper.auth'


.controller 'VerifyBeginCtrl', ['$scope', '$rootScope', 'App', 'CToast'
	, ($scope, $rootScope, App, CToast)->

		$rootScope.user = 
			name: 'Deepak Prabhudesai'
			phone: 9765436351

		$scope.onProceed = ->
			name  = $rootScope.user.name
			phone = $rootScope.user.phone
			#Check valid phone no
			if _.contains([name, phone], '') or _.isUndefined(phone)
				CToast.show 'Please enter all fields'
			else
				if App.isOnline()
					state = if App.isAndroid() then 'verify-auto' else 'verify-manual'
					App.navigate state
				else
					CToast.show 'No internet availability'
]