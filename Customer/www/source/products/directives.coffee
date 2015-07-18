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


.directive 'ajCountDown', ['$timeout', '$parse', ($timeout, $parse)->

	restrict: 'A'
	link: (scope, el, attrs)->
		
		$timeout ->
			createdAt = $parse(attrs.createdAt)(scope)

			m = moment createdAt
			total = moment(m).add 24, 'hours'
			totalStr = moment(total).format 'YYYY/MM/DD HH:mm:ss'

			$(el).countdown totalStr, (event)->
				$(el).html event.strftime('%-H:%-M:%-S')
]