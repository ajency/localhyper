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