angular.module 'LocalHyper.suggestProduct', []


.controller 'suggestProductCtrl', ['$q', '$scope', '$http', '$location', 'CToast', 'CategoriesAPI'
	, 'CSpinner'
	, ($q, $scope, $http, $location, CToast, CategoriesAPI, CSpinner)->

		$scope.suggest = {}

		CategoriesAPI.getAll()
		.then (categories)->
			console.log(categories)
			$scope.suggest.items = categories
		
		$scope.suggest = 
			productName: null
			category: null
			brand: null
			productDescription: null
			yourComments: null

			onSuggest :->
				if (@productName == null)
					CToast.show 'Please enter product Name'
				else if (@brand == null)
					CToast.show 'Please enter brand Name'
				else if (@category == null)
					CToast.show 'Please Select Category'
				else 
					CSpinner.show '', 'Please wait...'
					param = 
						"productName" : @productName
						"category" :@category.name
						"brand": @brand
						"description" : @productDescription
						"comments" : @yourComments

					$http.post 'functions/sendMail', param
					.then (data)->
						CToast.showLongBottom('Thank you for your time. We will do our best to accommodate your suggestion at the earliest.')
					, (error)->
						CToast.show('Request failed, please try again')
					.finally ->
						CSpinner.hide()
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'suggest-product',
			url: '/suggest-product'
			parent: 'main',
			cache: false,
			views: 
				"appContent":
					controller: 'suggestProductCtrl'
					templateUrl: 'views/suggest-product.html'
]
