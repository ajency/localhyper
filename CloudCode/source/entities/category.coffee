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
_ = require('underscore.js')
moment = require('cloud/moment')
# moment = require('cloud/moment-range-min')

treeify = (list, idAttr, parentAttr, childrenAttr) ->
  if !idAttr
    idAttr = 'id'
  if !parentAttr
    parentAttr = 'parent'
  if !childrenAttr
    childrenAttr = 'children'
  treeList = []
  lookup = {}
  list.forEach (obj) ->
    lookup[obj[idAttr]] = obj
    obj[childrenAttr] = []
    return
  list.forEach (obj) ->
    if obj[parentAttr] != null
      parentId = obj[parentAttr]
      lookup[parentId][childrenAttr].push obj
    else
      treeList.push obj
    return
  treeList

Parse.Cloud.define 'getCategories', (request, response) ->
  
  sortBy = request.params.sortBy
  
  # get all category list
  Category = Parse.Object.extend('Category')

  queryCategory = new Parse.Query(Category)
  queryCategory.include("parent_category")
  
  queryFindPromise = queryCategory.find()
  
  queryFindPromise.done (results) =>
    list = []

    _.each results , (resultobj) ->
      
      listObj = 
        id : resultobj.id
        name: resultobj.get('name')
        sort_order: resultobj.get('sort_order')
        image: resultobj.get('image')
        description: resultobj.get('description')
      
      if _.isObject(resultobj.get('parent_category'))
        parentCat = resultobj.get('parent_category')
        listObj['parent'] = parentCat.id
      else
        listObj['parent'] = null
      
      list.push listObj

    categoryHierarchyTree = treeify(list,'id','parent','children')


    responseData = 
      "success" : true
      "data" : _.sortBy categoryHierarchyTree, sortBy

    response.success responseData

  queryFindPromise.fail (error) =>
    responseData = 
      "success" : false
      "errorCode" : error.code
      "msg" : error.msg
    response.error responseData


