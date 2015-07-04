getAttribValueMapping = (categoryId,filterableAttributes=true,secondaryAttributes=false) ->
    Category = Parse.Object.extend('Category')
    Attributes = Parse.Object.extend('Attributes')
    AttributeValues = Parse.Object.extend('AttributeValues')

    # get category by given category id
    categoryQuery = new Parse.Query("Category")
    categoryQuery.equalTo("objectId", categoryId)
    categoryQuery.include("filterable_attributes")
    # categoryQuery.include("secondary_attributes")
    
    findCategoryPromise = categoryQuery.first()

    # for such category find all the filterable_attributes and secondary_attributes
    findCategoryPromise.done (categoryData) =>
        # filterable_attributes = categoryData.get('filterable_attributes')

        # _.each filterable_attributes, (f_attrib) ->
            
            # # query to get specific category
            # innerQuery = new Parse.Query("Attributes")
            # innerQuery.equalTo("objectId",attributeId)

            # # query to get products matching the child category
            # query = new Parse.Query("AttributeValues")
            # query.matchesQuery("attribute", innerQuery)
            
            # # output
            # [
            #   {
            #       "attribId":
            #       "attribName":
            #       "displayType":
            #       "attribValues": []

            #   }
            # ]         

        return categoryData


Parse.Cloud.define 'getAttribValueMapping', (request, response) ->
    categoryId = request.params.categoryId
    
    Category = Parse.Object.extend('Category')
    Attributes = Parse.Object.extend('Attributes')
    AttributeValues = Parse.Object.extend('AttributeValues')

    # get category by given category id
    categoryQuery = new Parse.Query("Category")
    categoryQuery.equalTo("objectId", categoryId)
    categoryQuery.include("filterable_attributes")
    # categoryQuery.include("secondary_attributes")
    
    findCategoryPromise = categoryQuery.first() 

    # for such category find all the filterable_attributes and secondary_attributes
    findCategoryPromise.done (categoryData) =>
        filterable_attributes = categoryData.get('filterable_attributes')
        
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
        

Parse.Cloud.job 'productImport', (request, response) ->

    ProductItem = Parse.Object.extend('ProductItem')

    productSavedArr = []

    products =  request.params.products

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


Parse.Cloud.define 'getProducts', (request, response) ->
  
    categoryId = request.params.categoryId
    selectedFilters = request.params.selectedFilters # "all" / {"brand": "","price": "", "otherAttrib"} 
    sortBy =  request.params.sortBy
    ascending = request.params.ascending
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit
    

    # get filterable attributes for the child category
    filterableAttribQuery = new Parse.Query("Category")
    filterableAttribQuery.equalTo("objectId",categoryId)
    filterableAttribQuery.select("filterable_attributes")
    filterableAttribQuery.include("filterable_attributes")

    findFilterableAttrib = filterableAttribQuery.find()

    findFilterableAttrib.done (filters) =>

        # get all category based products
        ProductItem = Parse.Object.extend("ProductItem")
        
        # query to get specific category
        innerQuery = new Parse.Query("Category")
        innerQuery.equalTo("objectId",categoryId)

        # query to get products matching the child category
        query = new Parse.Query("ProductItem");
        query.matchesQuery("category", innerQuery)

        if (selectedFilters isnt "all") and (_.isObject(selectedFilters))
            filterableProps = Object.keys(selectedFilters)

            if _.contains(filterableProps, "brand")
                brand = selectedFilters["brand"]
    
                innerBrandQuery = new Parse.Query("Brand")
                innerBrandQuery.equalTo("objectId",brand)
                query.matchesQuery("brand", innerBrandQuery)
            
            if _.contains(filterableProps, "price")
                price = selectedFilters["price"]
                
                startPrice = parseInt price[0]
                endPrice = parseInt price[1]
                
                query.greaterThanOrEqualTo("mrp", startPrice)
                query.lessThanOrEqualTo("mrp", endPrice)
                

        # restrict which fields are being returned
        query.select("images,name,mrp,brand")

        query.include("brand")
        # query.include("category")
        # query.include("attrs")
        # query.include("attrs.attribute")

        # pagination
        query.limit(displayLimit)
        query.skip(page * displayLimit)

        # sorting
        if ascending is true
            query.ascending(sortBy)
        else
            query.descending(sortBy)

        queryFindPromise =query.find()

        queryFindPromise.done (products) =>

            result = 
                products: products
                filters: filters
                sortableAttributes : ["mrp","popularity"]

            response.success result

        queryFindPromise.fail (error) =>
            response.error error.message

    findFilterableAttrib.fail (error) =>
        response.error error.message
    

Parse.Cloud.define 'getProduct', (request, response) ->  
    productId = request.params.productId 

    # get product by productID
    ProductItem = Parse.Object.extend("ProductItem")
    queryProductItem = new Parse.Query(ProductItem)

    queryProductItem.equalTo("objectId", productId)
    queryProductItem.include("attrs")
    queryProductItem.include("brand")
    queryProductItem.include("attrs.attribute")
    queryProductItem.include("category")

    queryProductItem.first()
    .then (ProductData)->
        response.success ProductData
    , (error)->
        response.error error    





    




