angular.module 'LocalHyper.products'


.directive 'ajLoadingBackDrop', ['$timeout', '$ionicLoading', ($timeout, $ionicLoading)->

	restrict: 'A'
	scope:
		onHidden: '&'

	link: (scope, el, attrs)->

		onContainerClick = (event)->
			target = $(event.target)
			if target.hasClass 'loading-container'
				$('.loading-container').off 'click', onContainerClick
				scope.$apply ->
					scope.onHidden()
			else if target.hasClass 'button-assertive'
				$('.loading-container').off 'click', onContainerClick
		
		$timeout ->
			$('.loading-container').on 'click', onContainerClick
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