angular.module 'LocalHyper.categories'


.controller 'SubCategoriesCtrl', ['$scope', 'SubCategory', ($scope, SubCategory)->

	$scope.view = 
		title: SubCategory.parentTitle
		subCategories: SubCategory.data
]


.config ['$stateProvider', ($stateProvider)->

	$stateProvider

		.state 'sub-categories',
			url: '/sub-categories:parentID'
			parent: 'main'
			views: 
				"appContent":
					templateUrl: 'views/categories/sub-categories.html'
					controller: 'SubCategoriesCtrl'
					resolve:
						SubCategory: ($stateParams, CategoriesAPI)->
							CategoriesAPI.getAll()
							.then (categories)->
								parent = _.filter categories, (category)->
									category.id is $stateParams.parentID

								children = parent[0].children
								CategoriesAPI.subCategories 'set', children
								parentTitle: parent[0].name, data: children
]