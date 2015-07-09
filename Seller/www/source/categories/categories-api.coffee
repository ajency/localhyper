angular.module 'LocalHyper.categories'


.factory 'CategoriesAPI', ['$q', '$http', ($q, $http)->

	CategoriesAPI = {}
	allCategories = []
	subCategories = []

	CategoriesAPI.getAll = ->
		defer = $q.defer()

		if _.isEmpty allCategories
			$http.post 'functions/getCategories', "sortBy": "sort_order"
			.then (data)->
				defer.resolve allCategories = data.data.result.data
			, (error)->
				defer.reject error
		else
			defer.resolve allCategories

		defer.promise

	CategoriesAPI.subCategories = (action, data={})->
		switch action
			when 'set'
				subCategories = data
			when 'get'
				subCategories

	CategoriesAPI
]