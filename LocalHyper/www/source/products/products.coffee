angular.module 'LocalHyper.products', []


.controller 'ProductsCtrl', ['$scope', ($scope)->

	console.log 'Products'

	

]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'products',
			url: '/products'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/products/products.html'
					controller: 'ProductsCtrl'
]