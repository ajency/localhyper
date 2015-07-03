angular.module 'LocalHyper.categories'


.factory 'CategoriesAPI', ['$q', ($q)->

	CategoriesAPI = {}
	allCategories = []

	CategoriesAPI.getAll = ->
		defer = $q.defer()

		if _.isEmpty allCategories
			Parse.Cloud.run 'getCategories', "sortBy": "sort_order"
			.then (data)->
				defer.resolve allCategories = data.data
			, (error)->
				defer.reject error
		else
			defer.resolve allCategories

		defer.promise

	CategoriesAPI
]