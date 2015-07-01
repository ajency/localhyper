# # Use Parse.Cloud.define to define as many cloud functions as you want.
# Category = Parse.Object.extend('Category')
# # Check if name is set, and enforce uniqueness based on the name column.
# Parse.Cloud.beforeSave 'Category', (request, response) ->
#   if !request.object.get('name')
#     response.error 'A Category must have a name.'
#   else
#     query = new (Parse.Query)(Category)
#     query.equalTo 'name', request.object.get('name')
#     query.first
#       success: (object) ->
#         if object
#           response.error 'A Category with this name already exists.'
#         else
#           response.success()
#         return
#       error: (error) ->
#         response.error 'Could not validate uniqueness for this Category object.'
#         return
#   return

Parse.Cloud.define 'generateCategoryHierarchy', (request, response) ->
  response.success 'Hello world!'
  return

