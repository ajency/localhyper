# Use Parse.Cloud.define to define as many cloud functions as you want.
# Parse.Cloud.define 'createProduct', (request, response) ->
	
# 	# create Product Item
# 	ProductItem = Parse.Object.extend('ProductItem')

# 	productData = request
# 	console.log productData
# 	productItem = new ProductItem productData

# 	productItem.save()
# 		.done (resp)=> 
# 			response.success resp

# 		.fail (error)=>
# 			 response.error 'Failed to create new object, with error code: ' + error.message
#   return
