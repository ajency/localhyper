angular.module 'LocalHyper.products'


.directive 'ajLoadingBackDrop', ['$timeout', '$ionicLoading', ($timeout, $ionicLoading)->

	restrict: 'A'
	link: (scope, el, attrs)->
		
		$timeout ->
			$('.loading-container').on 'click', (event)->
				isBackdrop = $(event.target).hasClass 'loading-container'
				if isBackdrop
					$ionicLoading.hide()
]


.factory 'PrimaryAttribute', [->

	PrimaryAttribute = {}

	PrimaryAttribute.get = (attrs)->
		if _.isUndefined(attrs) then ''
		else
			attrs = attrs[0]
			if _.contains(['N/A', 'NA'], attrs.value) then ''
			else
			    name = attrs.attribute.name
				value = s.humanize attrs.value
				unit = ''
				if _.has attrs.attribute, 'unit'
					unit = s.humanize attrs.attribute.unit
				"#{name} : #{value} #{unit}"

	PrimaryAttribute
]