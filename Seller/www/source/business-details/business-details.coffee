angular.module 'LocalHyper.businessDetails', []


.controller 'BusinessDetailsCtrl', ['$scope', 'CToast', 'App', 'GPS', 'GoogleMaps'
	, 'CDialog', 'User', '$timeout', 'Storage', 'BusinessDetails'
	, 'AuthAPI', 'CSpinner', '$q', '$rootScope', '$ionicPlatform', 'UIMsg'
	, ($scope, CToast, App, GPS, GoogleMaps, CDialog, User, $timeout
	, Storage, BusinessDetails, AuthAPI, CSpinner, $q, $rootScope, $ionicPlatform
	, UIMsg)->
	
		$scope.view = 
			name:''
			phone:''
			businessName:''
			confirmedAddress: ''
			terms: false
			myProfileState : if User.isLoggedIn() then true else false

			delivery:
				radius: 10
				plus : ->
					@radius++ if @radius < 25
				minus : ->
					@radius-- if @radius > 1

			workingDays:[
				{name: 'Mon', value: 'Monday', selected: false}
				{name: 'Tue', value: 'Tuesday', selected: false}
				{name: 'Wed', value: 'Wednesday', selected: false}
				{name: 'Thur', value: 'Thursday', selected: false}
				{name: 'Fri', value: 'Friday', selected: false}
				{name: 'Sat', value: 'Saturday', selected: false}
				{name: 'Sun', value: 'Sunday', selected: false}]

			location:
				modal: null
				map: null
				marker: null
				latLng: null
				address: null
				addressFetch: true

			init : ->
				@getStoredBusinessDetails()

			getStoredBusinessDetails : ->
				details = BusinessDetails
				if !_.isNull details 
					@name = details.name
					@phone = details.phone
					@businessName = details.businessName
					@confirmedAddress = details.confirmedAddress
					@delivery.radius =  details.deliveryRadius
					@latitude =  details.latitude
					@longitude =  details.longitude
					@location.address = details.address
					@workingDays = details.workingDays
					if App.previousState is 'choose-location'
						cordinates = GoogleMaps.setCordinates 'get'
						if !_.isEmpty cordinates
							@latitude =  cordinates.latitude
							@longitude =  cordinates.longitude
							if !_.isUndefined cordinates.addressObj
								@confirmedAddress = cordinates.addressObj.full
							@location.address = cordinates.addressObj
					else
						value = latitude: @latitude, longitude: @longitude
						GoogleMaps.setCordinates 'set' , value  
				else
					userInfo = User.info 'get'
					if !_.isUndefined userInfo.name
						@name = userInfo.name
					if !_.isUndefined userInfo.phone
						@phone = userInfo.phone
					if !_.isUndefined userInfo.businessName
						@businessName = userInfo.businessName
					cordinates = GoogleMaps.setCordinates 'get'
					if !_.isEmpty cordinates
						@latitude =  cordinates.latitude
						@longitude =  cordinates.longitude
						@confirmedAddress = cordinates.addressObj.full
						@location.address = cordinates.addressObj

			areWorkingDaysSelected : ->
				selected = _.pluck @workingDays, 'selected'
				_.contains selected, true

			getNonWorkingDays : ->
				offDays = []
				_.each @workingDays, (days)=>
					offDays.push(days.value) if !days.selected
				offDays

			checkNetwork : ->
				if App.isOnline()
					App.navigate 'choose-location'
				else
					CToast.show UIMsg.noInternet

			onChangeLocation : ->
				User.info 'set', $scope.view
				if _.isUndefined window.google
					CSpinner.show '', 'Please wait, loading resources'
					GoogleMaps.loadScript()
					.then => 
						@checkNetwork()
					,(error)-> 
						CToast.show 'Error loading content, please check your network settings'
					.finally -> 
						CSpinner.hide()
				else
					@checkNetwork()
					

			onNext : ->
				if _.contains [@businessName, @name, @phone], ''
					CToast.show 'Please fill up all fields'
				else if _.isUndefined @phone
					CToast.show 'Please enter valid phone number'
				else if @confirmedAddress is ''
					CToast.show 'Please select your location'
				else if !@areWorkingDaysSelected()
					CToast.show 'Please select your working days'
				else
					@offDays = @getNonWorkingDays()
					
					if @myProfileState
						CSpinner.show '', 'Please wait...'
						User.info 'set', $scope.view
						AuthAPI.isExistingUser $scope.view
						.then (data)->
							AuthAPI.loginExistingUser data.userObj
						.then (success)=>
							CToast.show 'Saved business details'
							$rootScope.$broadcast 'category:chain:updated'
							@saveBussinessDetails().then ->
								App.navigate 'my-profile'
						, (error)->
							CToast.show 'Could not connect to server, please try again.'
						.finally ->
							CSpinner.hide()
					else
						User.info 'set', $scope.view
						@saveBussinessDetails().then ->
							App.navigate 'category-chains'

			saveBussinessDetails :->
				Storage.bussinessDetails 'set',
					name: @name
					phone: @phone
					businessName: @businessName
					address: @location.address
					confirmedAddress: @confirmedAddress
					latitude: @latitude
					longitude: @longitude
					deliveryRadius: @delivery.radius
					location: address:@location.address
					delivery: radius: @delivery.radius
					workingDays : @workingDays
					offDays : @getNonWorkingDays()


		onDeviceBack = ->
			# locationModal = $scope.view.location.modal
			# if !_.isNull(locationModal) && locationModal.isShown()
			# 	locationModal.hide()
			# else
			App.goBack -1

		$scope.$on '$destroy', ->
			$ionicPlatform.offHardwareBackButton onDeviceBack
			# locationModal = $scope.view.location.modal
			# locationModal.remove() if !_.isNull(locationModal)

		$scope.$on '$ionicView.enter', ->
			$ionicPlatform.onHardwareBackButton onDeviceBack
			App.hideSplashScreen()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'business-details',
			url: '/business-details'
			parent: 'main'
			cache: false
			views: 
				"appContent":
					controller: 'BusinessDetailsCtrl'
					templateUrl: 'views/business-details/business-details.html'
					resolve:
						BusinessDetails : ($q, Storage)->
							defer = $q.defer()
							Storage.bussinessDetails 'get'
							.then (details)->
								defer.resolve details
							defer.promise
]

