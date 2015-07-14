Parse.Cloud.define 'getAttribValueMapping', (request, response) ->
    categoryId = request.params.categoryId
    filterableAttributes = request.params.filterableAttributes
    secondaryAttributes = request.params.secondaryAttributes    
    
    Category = Parse.Object.extend('Category')
    Attributes = Parse.Object.extend('Attributes')
    AttributeValues = Parse.Object.extend('AttributeValues')

    # get category by given category id
    categoryQuery = new Parse.Query("Category")
    categoryQuery.equalTo("objectId", categoryId)

    if filterableAttributes
        categoryQuery.include("filterable_attributes")
    if secondaryAttributes
        categoryQuery.include("secondary_attributes")
    
    findCategoryPromise = categoryQuery.first() 

    # for such category find all the filterable_attributes and secondary_attributes
    findCategoryPromise.done (categoryData) =>
        filterable_attributes = []

        if filterableAttributes
            filterable_attributes = categoryData.get('filterable_attributes')

        if secondaryAttributes
           filterable_attributes = _.union(filterable_attributes, categoryData.get('secondary_attributes') )         
        
        findQs = []

        findQs = _.map(filterable_attributes, (attribute) ->
            
            attributeId = attribute.id
            attributeValues = []

            # query to get specific category
            innerQuery = new Parse.Query("Attributes")
            innerQuery.equalTo("objectId",attributeId)

            # query to get attributeValues having the attributeId
            query = new Parse.Query("AttributeValues")
            query.matchesQuery("attribute", innerQuery)
            query.include("attribute")
            query.find()
        )

        Parse.Promise.when(findQs).then ->

            individualFindResults = _.flatten(_.toArray(arguments))

            finalArr = []
            _.each individualFindResults , (individualResult) ->
                
                object =
                    "attributeId" : individualResult.get("attribute").id
                    "attributeName" : individualResult.get("attribute").get "name"
                    "group" : individualResult.get("attribute").get "group"
                    "displayType" : individualResult.get("attribute").get "displayType"
                    "valueId" : individualResult.id
                    "value" : individualResult.get "value"
                
                finalArr.push object
            
            Parse.Promise.as()  
            response.success finalArr 
        , (error)->
            response.error error

Parse.Cloud.define 'attributeImport', (request, response) ->

    Attributes = Parse.Object.extend('Attributes')

    attributeSavedArr = []

    attributes =  request.params.attributes
    categoryId =  request.params.categoryId
    isFilterable =  request.params.isFilterable

    _.each attributes, (attributeObj) ->
        attribute = new Attributes()

        # if(attributeObj.hasOwnProperty("objectId"))
        if attributeObj.objectId isnt ""
            attribute.id = attributeObj.objectId


        attribute.set "name", attributeObj.name

        attribute.set "group", attributeObj.group
        
        if attributeObj.unit isnt ""       
            attribute.set "unit", attributeObj.unit

        attribute.set "display_type", attributeObj.display_type

        attributeSavedArr.push(attribute)
        

    # save all the newly created objects
    Parse.Object.saveAll attributeSavedArr,
      success: (objs) ->

        # get category and update its filterable column
        Category = Parse.Object.extend('Category')
        category = new Category()
        category.id = categoryId

        if isFilterable is true
            category.set "filterable_attributes" , objs
        else
            category.set "secondary_attributes" , objs    
        
        category.save()
        .then ()->
            response.success "Successfully added/updated the attributes"
        , (error) ->
            response.error error

      error: (error) ->
        response.error "Failed to add/update attributes due to - #{error.message}"    

Parse.Cloud.define 'attributeValueImport', (request, response) ->

    AttributeValues = Parse.Object.extend('AttributeValues')
    
    attributeValSavedArr = []

    attributeValues =  request.params.attributeValues
    categoryId =  request.params.categoryId

    _.each attributeValues, (attributeValObj) ->
        attributeValue = new AttributeValues()

        if attributeValObj.objectId isnt ""
            attributeValue.id = attributeValObj.objectId


        attributeValue.set "value", attributeValObj.value

        attributePointer = 
            "__type" : "Pointer",
            "className":"Attributes",
            "objectId":attributeValObj.attributeId            
        
        attributeValue.set "attribute", attributePointer

        attributeValSavedArr.push(attributeValue)
        

    # save all the newly created objects
    Parse.Object.saveAll attributeValSavedArr,
      success: (objs) ->
        response.success "Successfully added/updated the attributes"

      error: (error) ->
        response.error "Failed to add/update attributes due to - #{error.message}"      

