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
        categoryQuery.include("filterable_attributes.filterAttribute")
    if secondaryAttributes
        categoryQuery.include("secondary_attributes")
    
    findCategoryPromise = categoryQuery.first() 

    # for such category find all the filterable_attributes and secondary_attributes
    findCategoryPromise.done (categoryData) =>

        final_attributes = []

        if filterableAttributes
            filterable_attributes = categoryData.get('filterable_attributes')

            if (filterable_attributes)
                if filterable_attributes.length > 0
                    f_attributes = []
                    f_attributes = _.map(filterable_attributes, (filterObj) ->
                        filterObj.get("filterAttribute")
                    )

                    final_attributes = f_attributes

        if secondaryAttributes
            secondary_attributes = categoryData.get('secondary_attributes')

            if (secondary_attributes)
                if secondary_attributes.length > 0
                    final_attributes = _.union(f_attributes, secondary_attributes )         
        
        
        findQs = []

        findQs = _.map(final_attributes, (attribute) ->
            
            attributeId = attribute.id
            attributeValues = []

            # query to get specific category
            innerQuery = new Parse.Query("Attributes")
            innerQuery.equalTo("objectId",attributeId)

            # query to get attributeValues having the attributeId
            query = new Parse.Query("AttributeValues")
            query.matchesQuery("attribute", innerQuery)
            query.include("attribute")
            query.limit(500)
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

            attributes = _.map(final_attributes, (attribute) ->
                
                attribute = 
                    "id" : attribute.id
                    "name" : attribute.get("name")
                    "type" : attribute.get("type")
            )


            result = 
                attributes :  attributes
                attributeValues : finalArr
            response.success result 
        , (error)->
            response.error error

Parse.Cloud.define 'attributeImport', (request, response) ->

    Attributes = Parse.Object.extend('Attributes')

    attributeSavedArr = []

    attributes =  request.params.attributes # (all except primary)
    categoryId =  request.params.categoryId
    isFilterable =  request.params.isFilterable # true or false
    primaryAttributeObj =  request.params.primaryAttributeObj # (empty object if no primary attribute sent)

    # prepare attributes array to be saved/updated from input data
    _.each attributes, (attributeObj) ->
        if !_.isNull(attributeObj.name)
            attribute = new Attributes()

            # if(attributeObj.hasOwnProperty("objectId"))
            if !_.isNull(attributeObj.objectId)
                attribute.id = attributeObj.objectId


            attribute.set "name", attributeObj.name

            attribute.set "group", attributeObj.group
            
            if !_.isNull(attributeObj.unit)     
                attribute.set "unit", attributeObj.unit

            if(attributeObj.hasOwnProperty("display_type"))
                attribute.set "display_type", attributeObj.display_type
            else
                attribute.set "display_type", "checkbox" 

            if(attributeObj.hasOwnProperty("type"))
                attribute.set "type", attributeObj.type
            else
                attribute.set "type", "select"         

            attributeSavedArr.push(attribute)    

    # set primary_attributes column for category
    primaryAttributeSavedArr = []

    # save/update primary attribute
    setPrimaryAttribute(primaryAttributeObj)
    .then (primaryobj) ->

        # save/updated all the newly attributes
        Parse.Object.saveAll (attributeSavedArr)
        .then (objs) ->

            if !(_.isEmpty(primaryobj))
                objs.push primaryobj


            # get category and update its filterable column
            Category = Parse.Object.extend('Category')
            category = new Category()
            category.id = categoryId
            
            ProductFilters = Parse.Object.extend('ProductFilters') 

            if isFilterable is true
                # if filterable is true then insert into ProductFilters table

                #  i.e. first remove all previus entries for the categoryId and make fresh new insert 
                queryProdFilters = new Parse.Query('ProductFilters')
                queryProdFilters.equalTo("categoryId",categoryId)
                queryProdFilters.find()
                .then (oldCategoryFilters)->

                    Parse.Object.destroyAll(oldCategoryFilters)
                    .then (destroyedObjs) ->
                        filterColumn = 1
                        filterableAttribArr = []
                        
                        _.each objs , (obj) ->
                            productFilters = new ProductFilters()
                
                            productFilters.set "categoryId" , categoryId
                            productFilters.set "filterColumn" , filterColumn
                            productFilters.set  "filterAttribute" , obj
                            filterColumn++
                            filterableAttribArr.push productFilters
                        
                        # save all the filters for the category
                        Parse.Object.saveAll (filterableAttribArr)  
                        .then (savedFilters) ->
                            category.set "filterable_attributes" , savedFilters
                           
                            # set primary attribute for category only if not empty
                            if !(_.isEmpty(primaryobj))
                                primaryAttributeSavedArr.push primaryobj   
                                category.set "primary_attributes" , primaryAttributeSavedArr

                            category.save()
                            .then (categoryObj)->
                                successObj = 
                                    success: true
                                    message: "Successfully added/updated the attributes (with primary)"
                                response.success successObj
                            , (error) ->
                                response.error error

                        , (error) ->
                            response.error error

                    , (error) ->
                        response.error "1. error due to #{error}"
                    

                ,(error) ->
                    response.error error
            else
                category.set "secondary_attributes" , objs  

                if !(_.isEmpty(primaryobj))
                    primaryAttributeSavedArr.push primaryobj   
                    category.set "primary_attributes" , primaryAttributeSavedArr

                category.save()
                .then (categoryObj)->
                    successObj = 
                        success: true
                        message: "Successfully added/updated the attributes (with primary)"
                    response.success successObj
                , (error) ->
                    response.error error

          ,(error) ->
            response.error "Failed to add/update attributes due to - #{error.message}"              


    ,(error) ->        
        response.error "Failed to save/update primary attribute due to - #{error.message}" 
      

Parse.Cloud.define 'attributeValueImport', (request, response) ->

    AttributeValues = Parse.Object.extend('AttributeValues')
    
    attributeValSavedArr = []

    attributeValues =  request.params.attributeValues
    categoryId =  request.params.categoryId

    _.each attributeValues, (attributeValObj) ->
        
        if (!_.isNull(attributeValObj.attributeId)) and (!_.isNull(attributeValObj.value))
            attributeValue = new AttributeValues()

            if !_.isNull(attributeValObj.objectId)
                attributeValue.id = attributeValObj.objectId

            value = String attributeValObj.value
            attributeValue.set "value", value

            attributePointer = 
                "__type" : "Pointer",
                "className":"Attributes",
                "objectId":attributeValObj.attributeId            
            
            attributeValue.set "attribute", attributePointer

            attributeValSavedArr.push(attributeValue)
        

    # save all the newly created objects
    Parse.Object.saveAll attributeValSavedArr,
      success: (objs) ->
        successObj = 
            success: true
            message: "Successfully added/updated the attribute valuess"
        response.success successObj

      error: (error) ->
        response.error "Failed to add/update attributes due to - #{error.message}"      

setPrimaryAttribute =  (primaryAttributeObj ) ->
    Attributes = Parse.Object.extend('Attributes')
    promise = new Parse.Promise()

    if _.isEmpty(primaryAttributeObj) or _.isNull(primaryAttributeObj.name)
        primaryAttributeObj = {}
        promise.resolve primaryAttributeObj

    else
        # set primary_attributes column and import attributes
        pAttrib = new Attributes()

        # if(attributeObj.hasOwnProperty("objectId"))
        if !_.isNull(primaryAttributeObj.objectId)
            pAttrib.id = primaryAttributeObj.objectId


        pAttrib.set "name", primaryAttributeObj.name

        pAttrib.set "group", primaryAttributeObj.group
        
        if primaryAttributeObj.unit isnt ""       
            pAttrib.set "unit", primaryAttributeObj.unit

        if(primaryAttributeObj.hasOwnProperty("display_type"))
            pAttrib.set "display_type", primaryAttributeObj.display_type
        else
            pAttrib.set "display_type", "checkbox" 

        if(primaryAttributeObj.hasOwnProperty("type"))
            pAttrib.set "type", primaryAttributeObj.type
        else
            pAttrib.set "type", "select" 

        pAttrib.save()
        .then (savedPrimaryObj) ->
            promise.resolve savedPrimaryObj

        , (error)->
            promise.reject error
        
    promise



