# saveJsonPerson = (fileTestSave) ->
#   #Get the pffile testfile
#   testFile = fileTestSave.get('testFile')
#   #get the fileURL from the PFFile to generate the http request
#   fileURL = testFile['url']()
#   #return the promise from the httpRequest
#   Parse.Cloud.httpRequest(
#     method: 'GET'
#     url: fileURL).then ((httpResponse) ->
#     #return the promise from the parsing
#     parsehttpResponse httpResponse, fileTestSave
#   ), (error) ->
#     console.log 'http response error'
#     return

# parsehttpResponse = (httpResponse, fileTestSave) ->
#   jsonArray = eval('(' + httpResponse.text + ')')
#   saveArray = []
#   #parse each person in the json string, and add them to the saveArray for bulk saving later.
#   for i of jsonArray
#     `i = i`
#     personExtend = Parse.Object.extend('Person')
#     person = new personExtend
#     person.set 'classDiscriminator', jsonArray[i]['classDiscriminator']
#     person.set 'lastName', jsonArray[i]['lastName']
#     person.set 'firstName', jsonArray[i]['firstName']
#     person.set 'employeeID', jsonArray[i]['employeeID']
#     saveArray.push person
#   #return the promise from the saveAll(bulk save)
#   Parse.Object.saveAll(saveArray).then (->
#     #return the promise from the destory
#     fileTestSave.destroy().then (->
#     ), (error) ->
#       console.log 'error destroying'
#       return
#   ), (error) ->
#     console.log 'Error Saving'
#     return

# Parse.Cloud.job 'userMigration', (request, status) ->
#   # Set up to modify user data
#   Parse.Cloud.useMasterKey()
#   #Table called fileTestSave stores a PFFile called "testFile" which we will use an HTTPRequest to get the data. Is there a better way to get the data?
#   #This PFFile stores a json string which contains relavent data to add to the "Person" table
#   testFileSave = Parse.Object.extend('fileTestSave')
#   query = new (Parse.Query)(testFileSave)
#   query.find().then((results) ->
#     #Generate an array of promises
#     promises = []
#     _.each results, (testFileSaveInstance) ->
#       #add promise to array
#       promises.push saveJsonPerson(testFileSaveInstance)
#       return
#     #only continue when all promises are complete
#     Parse.Promise.when promises
#   ).then (->
#     # Set the job's success status
#     console.log 'Migration Completed NOW'
#     status.success 'Migration completed'
#     return
#   ), (error) ->
#     # Set the job's error status
#     status.error 'Uh oh, something went wrong.'
#     return
#   return


Parse.Cloud.job 'productImport', (request, response) ->

	# get product json to be imported
	BulkImport = Parse.Object.extend('bulkImport')

	query = new Parse.Query(BulkImport)
	query.include("import_based_id")
	queryFindPromise = query.find()
	queryFindPromise.done (results) =>
		ProductItem = Parse.Object.extend('ProductItem')

		productSavedArr = []

		_.each results, (result) ->
			
			products =  result.get("json")

			_.each products, (product) ->
				productItem = new ProductItem()
				productItem.set "name", product.name
				productItem.set "images", product.images
				productItem.set "model_number", product.model_number
				productItem.set "mrp", parseInt product.mrp
				productItem.set "popularity", product.popularity
				productItem.set "group", product.group

				# set product category
				categoryObj = 
					"__type" : "Pointer",
					"className":"Category",
					"objectId":product.category

				productItem.set "category", categoryObj	
				
				# set brand
				brandObj =
					"__type" : "Pointer",
					"className":"Brand",
					"objectId":product.brand					

				productItem.set "brand", brandObj	
				
				attributeValueArr = []
				attributes = product.attrs

				_.each attributes, (attributeId) ->
					attribObj = 
						"__type" : "Pointer",
						"className":"AttributeValues",
						"objectId":attributeId

					attributeValueArr.push(attribObj)

				productItem.set "attrs", attributeValueArr						


				productSavedArr.push(productItem)
			
	
		# save all the newly created objects
		Parse.Object.saveAll productSavedArr,
		  success: (objs) ->
		    response.success "Successfully added the products"
		    return
		  error: (error) ->
		    response.error "Failed to add products due to - #{error.message}"
		
	queryFindPromise.fail (error) ->
		response.error "Error in products upload - #{error.message}"
	

	

	




