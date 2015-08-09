angular.module 'LocalHyper.businessDetails', []


.controller 'BusinessDetailsCtrl', ['$scope', 'CToast', 'App', 'GPS', 'GoogleMaps'
	, 'CDialog', 'User', '$ionicModal', '$timeout', 'Storage', 'BusinessDetails'
	, 'AuthAPI', 'CSpinner', '$cordovaDatePicker', '$q', '$rootScope'
	, ($scope, CToast, App, GPS, GoogleMaps, CDialog, User, $ionicModal, $timeout
	, Storage, BusinessDetails, AuthAPI, CSpinner, $cordovaDatePicker, $q, $rootScope)->
	
		$scope.view = 
			name:''
			phone:''
			businessName:''
			confirmedAddress: ''
			terms: false
			myProfileState : App.previousState is 'my-profile'

			delivery:
				radius: 10
				plus : ->
					@radius++ if @radius < 100
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

			workTimings: start: '', end: ''

			location:
				modal: null
				map: null
				marker: null
				latLng: null
				address: null
				addressFetch: true

				loadModal : ->
					defer = $q.defer()
					if _.isNull @modal
						$ionicModal.fromTemplateUrl 'views/business-details/location.html', 
							scope: $scope,
							animation: 'slide-in-up'
							hardwareBackButtonClose: true
						.then (modal)=> 
							defer.resolve @modal = modal
					else defer.resolve()
					defer.promise

				showAlert : ->
					positiveBtn = if App.isAndroid() then 'Open Settings' else 'Ok'
					CDialog.confirm 'Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']
					.then (btnIndex)->
						if btnIndex is 1
							GPS.switchToLocationSettings()

				onMapCreated : (map)->
					@map = map
					google.maps.event.addListener @map, 'click', (event)=>
						@addMarker event.latLng

				setMapCenter : (loc)->
					latLng = new google.maps.LatLng loc.lat, loc.long
					@map.setCenter latLng
					latLng

				getCurrent : ->
					GPS.isLocationEnabled()
					.then (enabled)=>
						if !enabled
							@showAlert()
						else
							CToast.show 'Getting current location'
							GPS.getCurrentLocation()
							.then (loc)=>
								latLng = @setMapCenter loc
								@map.setZoom 15
								@addMarker latLng
							, (error)->
								CToast.show 'Error locating your position'

				addMarker : (latLng)->
					@latLng = latLng
					@setAddress()
					@marker.setMap null if @marker
					@marker = new google.maps.Marker
						position: latLng
						map: @map
						draggable: true

					@marker.setMap @map
					google.maps.event.addListener @marker, 'dragend', (event)=>
						@latLng = event.latLng
						@setAddress()

				setAddress : ->
					@addressFetch = false
					GoogleMaps.getAddress @latLng
					.then (address)=>
						@address = address
					, (error)->
						console.log 'Geocode error: '+error
					.finally =>
						@addressFetch = true

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
					@workTimings = details.workTimings
					@workingDays = details.workingDays

			isGoogleMapsScriptLoaded : ->
				defer = $q.defer()
				if typeof google is 'undefined'
					CSpinner.show '', 'Please wait, loading resources...'
					GoogleMaps.loadScript()
					.then =>
						@location.loadModal()
					.then ->
						defer.resolve true
					, (error)->
						CToast.show 'Could not connect to server. Please try again'
						defer.resolve false
					.finally ->
						CSpinner.hide()
				else
					@location.loadModal().then ->
						defer.resolve true
				defer.promise

			areWorkingDaysSelected : ->
				selected = _.pluck @workingDays, 'selected'
				_.contains selected, true

			getNonWorkingDays : ->
				offDays = []
				_.each @workingDays, (days)=>
					offDays.push(days.value) if !days.selected
				offDays

			addWorkTimings : (type)->
				if App.isWebView()
					options = 
						date: new Date()
						mode: 'time'
						is24Hour: true
						okText: 'Set'
						androidTheme: 5
					$cordovaDatePicker.show options
					.then (date)=>
						@workTimings[type] = moment(date).format 'HH:mm:ss'
				else
					@workTimings.start = '9:00:00'
					@workTimings.end = '18:00:00'

			onChangeLocation : ->
				@isGoogleMapsScriptLoaded().then (loaded)=>
					if loaded
						@location.modal.show()
						mapHeight = $('.map-content').height() - $('.address-inputs').height() - 10
						$('.aj-big-map').css 'height': mapHeight
						if not _.isUndefined @latitude
							$timeout =>
								loc = lat: @latitude, long: @longitude
								latLng = @location.setMapCenter loc
								@location.map.setZoom 15
								@location.addMarker latLng
							, 200
						else if _.isNull @location.latLng
							$timeout =>
								loc = lat: GEO_DEFAULT.lat, long: GEO_DEFAULT.lng
								@location.setMapCenter loc
								@location.getCurrent()
							, 200

			onConfirmLocation : ->
				if !_.isNull(@location.latLng) and @location.addressFetch
					@location.address.full = GoogleMaps.fullAddress(@location.address)
					@confirmedAddress = @location.address.full
					@latitude = @location.latLng.lat()
					@longitude = @location.latLng.lng()
					@location.modal.hide()
				else
					CToast.show 'Please wait, getting location details...'

			onNext : ->
				if _.contains [@businessName, @name, @phone], ''
					CToast.show 'Please fill up all fields'
				else if _.isUndefined @phone
					CToast.show 'Please enter valid phone number'
				else if @confirmedAddress is ''
					CToast.show 'Please select your location'
				else if !@areWorkingDaysSelected()
					CToast.show 'Please select your working days'
				else if _.contains [@workTimings.start, @workTimings.end], ''
					CToast.show 'Please select your work timings'
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
					workTimings: @workTimings
					workingDays : @workingDays
					offDays : @getNonWorkingDays()
		

		$scope.$on '$destroy', ->
			locationModal = $scope.view.location.modal
			locationModal.remove() if !_.isNull(locationModal)

		$scope.$on '$ionicView.enter', ->
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

