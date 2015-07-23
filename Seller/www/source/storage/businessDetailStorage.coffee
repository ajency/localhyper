angular.module 'LocalHyper.BusinessDetailStorage', []


.factory 'BusinessDetailStorage', [->

	BusinessStorage = 

		setData: (val)->
			
			localforage.setItem val


		setBussinessName: (businessName) ->
			localforage.setItem 'businessName', businessName

		setFullName: (fullName) ->
			localforage.setItem 'fullName', fullName

		setPhoneNo: (phoneNo) ->
			localforage.setItem 'phoneNo', phoneNo

		setRadius: (radius) ->
			localforage.setItem 'radius', radius

		setAddress: (address) ->
			localforage.setItem 'address', address


		getBussinessName: () ->
			businessName = localforage.getItem 'businessName'

		getFullName: () ->
			fullName = localforage.getItem 'fullName'

		getPhoneNo: () ->
			phoneNo = localforage.getItem 'phoneNo'

		getRadius: () ->
			radius = localforage.getItem 'radius'

		getAddress: () ->
			address = localforage.getItem 'address'

	
	BusinessStorage


]


