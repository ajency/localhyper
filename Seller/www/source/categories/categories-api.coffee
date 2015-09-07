angular.module 'LocalHyper.categories'


.factory 'CategoriesAPI', ['$q', '$http', 'User', ($q, $http, User)->

	CategoriesAPI = {}
	allCategories = []
	subCategories = []
	categoryChains = []

	CategoriesAPI.getAll = ->
		defer = $q.defer()

		if _.isEmpty allCategories
			$http.post 'functions/getCategories', "sortBy": "sort_order"
			.then (data)->
				defer.resolve allCategories = data.data.result
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

	CategoriesAPI.categoryChains = (action, data={})->
		switch action
			when 'set'
				categoryChains = data
			when 'get'
				categoryChains

	CategoriesAPI.updateUnseenRequestNotification = (param)->
		defer = $q.defer()
		user = User.getCurrent()

		params = 
			"sellerId": user.id
			"changedData" : param.changedData

		$http.post 'functions/updateUnseenRequestNotification', params
		.then (success)->
			defer.resolve success
		, (error)->
			defer.reject error
		
		defer.promise

	CategoriesAPI
]