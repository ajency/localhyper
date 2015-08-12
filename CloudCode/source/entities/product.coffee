# tested for atmost 379 products, times out for products more than that
Parse.Cloud.define  'productImport', (request, response) ->
    ProductItem = Parse.Object.extend('ProductItem')

    productSavedArr = []

    importedProductCount = 0

    products =  request.params.products

    categoryId = request.params.categoryId
    priceRange = request.params.priceRange

    # get category data
    queryCategory = new Parse.Query("Category")

    queryCategory.equalTo("objectId", categoryId)

    queryCategory.include("filterable_attributes")
    queryCategory.include("secondary_attributes")
    queryCategory.include("filterable_attributes.filterAttribute")
    queryCategory.include("primary_attributes")
    queryCategory.select("filterable_attributes","primary_attributes", "secondary_attributes")    

    queryCategory.first()

    .then (categoryObj) ->
        totalAttrCount = 0
        if !_.isUndefined(categoryObj.get("filterable_attributes"))
            countFilterableAttrib = categoryObj.get("filterable_attributes").length
            
        if !_.isUndefined(categoryObj.get("secondary_attributes"))
            countSecAttrib = categoryObj.get("secondary_attributes").length

        totalAttrCount = countFilterableAttrib + countSecAttrib

        _.each products, (product) ->
            lengthOfAttr = _.keys(product.attrs).length
            lengthOfTextAttr = _.keys(product.text_attributes).length
            validAttrLength = lengthOfAttr + lengthOfTextAttr
            
            if !_.isNull(product.name) and (validAttrLength is totalAttrCount) and !_.isNull(product.brandId) 
                importedProductCount++
                productItem = new ProductItem()

                if !_.isNull(product.objectId)
                    productItem.id = product.objectId

                productAttributes = product.attrs

                # set direct columns of product item
                productItem.set "name", product.name

                productImgs = []
                inputImages = product.images
                _.each product.images , (productImage) ->

                    # if !_.isNull(productImage.src)
                    prodImg = 
                        "src" : productImage.src
                    # else
                    #     prodImg = 
                    #         "src" : "https://placehold.it/350x150?text=Product"

                    productImgs.push prodImg

                productItem.set "images", productImgs


                productItem.set "model_number", String (product.model_number)
                productItem.set "mrp", parseInt product.mrp
                productItem.set "popularity", parseInt product.popularity
                productItem.set "group", product.group 

                # set product brand
                brandObj =
                    "__type" : "Pointer",
                    "className":"Brand",
                    "objectId":product.brandId                    

                productItem.set "brand", brandObj        

                productItem.set "category", categoryObj 

                # set text attributes
                if !(_.isEmpty(product.text_attributes))
                    productItem.set "textAttributes" , product.text_attributes


                # get primary attribute from category and set that as primary attribute column 
                categoryPrimaryAttribute = categoryObj.get("primary_attributes")
                
                if !_.isUndefined(categoryPrimaryAttribute)
                    primeAttrib =_.first(categoryPrimaryAttribute)
                    primaryAttributeValueArr = []
                    primaryAttribObj = 
                        "__type" : "Pointer",
                        "className":"AttributeValues",
                        "objectId":productAttributes[primeAttrib.id]
                        
                    primaryAttributeValueArr.push(primaryAttribObj) 

                    productItem.set "primaryAttributes", primaryAttributeValueArr 

                # set product filters columns
                productFilters =  categoryObj.get "filterable_attributes"
                
                _.each productFilters, (productFilter) ->
                    columnPosition = productFilter.get("filterColumn") 
                    columnName = "filter#{columnPosition}"
                    filterAttribId = productFilter.get("filterAttribute").id

            
                    filterValueToSet = productAttributes[filterAttribId]

                    AttributeValues = Parse.Object.extend("AttributeValues")
                    fattributeValues = new AttributeValues()
                    fattributeValues.id = filterValueToSet
                   

                    if !_.isUndefined(filterValueToSet)
                        productItem.set columnName, fattributeValues 

                # set all attributes of product 
                attributeValueArr = []

                _.each productAttributes, (attrib) ->
                    attribObj = 
                        "__type" : "Pointer",
                        "className":"AttributeValues",
                        "objectId":attrib

                    attributeValueArr.push(attribObj)

                productItem.set "attrs", attributeValueArr                                          


                productSavedArr.push(productItem)  

        # save all the newly created objects
        Parse.Object.saveAll productSavedArr
          .then (objs) ->
            categoryObj.set "price_range" , priceRange
            categoryObj.save()
            .then (savedCat)->
                response.success "Successfully added #{importedProductCount} products"
            , (error) ->
                response.error "Failed to add products due to - #{error.message}"
          , (error) ->
            response.error "Failed to add products due to - #{error.message}" 

    , (error) ->
        response.error error           

Parse.Cloud.define 'getProducts', (request, response) ->
  
    categoryId = request.params.categoryId
    selectedFilters = request.params.selectedFilters # "all" / {"brand": "","price": "", "other_filters": [{"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}, {"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}]} 
    sortBy =  request.params.sortBy
    ascending = request.params.ascending
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit
    

    # get filterable attributes for the child category
    filterableAttribQuery = new Parse.Query("Category")
    filterableAttribQuery.equalTo("objectId",categoryId)
    filterableAttribQuery.select("filterable_attributes")
    filterableAttribQuery.select("supported_brands")
    filterableAttribQuery.select("price_range")
    filterableAttribQuery.include("filterable_attributes")
    filterableAttribQuery.include("supported_brands")

    findFilterableAttrib = filterableAttribQuery.first()

    findFilterableAttrib.done (categoryData) =>
        filters = categoryData.get "filterable_attributes"
        supported_brands = categoryData.get "supported_brands"
        price_range = categoryData.get "price_range"

        # get all category based products
        ProductItem = Parse.Object.extend("ProductItem")
        
        # query to get specific category
        innerQuery = new Parse.Query("Category")
        innerQuery.equalTo("objectId",categoryId)

        # query to get products matching the child category
        query = new Parse.Query("ProductItem")
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

            if _.contains(filterableProps, "other_filters")
                AttributeValues = Parse.Object.extend('AttributeValues')
                otherFilters = selectedFilters['other_filters']
                # otherFilters = [[attribValueId1, attribBalueId2], [attribBalueId3],[attribBalueId4,attribBalueId5]]

                # applying multiple constraints is like an AND on constraints
                _.each otherFilters , (sameAttribFilters) ->
                    AttributeValues = Parse.Object.extend("AttributeValues")
                    attribValuePointers = []
                    attribValuePointers = _.map(sameAttribFilters, (attribValueId) ->
                        AttributeValuePointer = new AttributeValues()
                        AttributeValuePointer.id = attribValueId
                        AttributeValuePointer
                    )

                    query.containedIn('attrs', attribValuePointers)

                # lists objects matching any of the values in a list of value (can be used for OR condition)


        # restrict which fields are being returned
        query.select("images,name,mrp,brand,primaryAttributes")

        query.include("brand")
        # query.include("category")
        query.include("primaryAttributes")
        query.include("primaryAttributes.attribute")

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
                supportedBrands: supported_brands
                priceRange: price_range
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
    queryProductItem.include("primaryAttributes")
    queryProductItem.include("primaryAttributes.attribute")

    queryProductItem.first()
    .then (ProductData)->
        response.success ProductData
    , (error)->
        response.error error    


Parse.Cloud.define 'getProductsNew', (request, response) ->
    categoryId = request.params.categoryId
    selectedFilters = request.params.selectedFilters # "all" / {"brand": "","price": "", "other_filters": [{"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}, {"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}]} 
    sortBy =  request.params.sortBy
    ascending = request.params.ascending
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit
    

    # get filterable attributes for the child category
    categoryQuery = new Parse.Query("Category")
    categoryQuery.equalTo("objectId",categoryId)
    categoryQuery.select("filterable_attributes")
    categoryQuery.select("supported_brands")
    categoryQuery.select("price_range")
    categoryQuery.include("filterable_attributes")
    categoryQuery.include("filterable_attributes.filterAttribute")
    categoryQuery.include("supported_brands")

    categoryQuery.first()
    .then (categoryData) ->
        filters = categoryData.get "filterable_attributes"
        displayFilters = []

        findAttribValuesQs = _.map(filters, (filter) ->
            
            findAttribValues(filter)
        )

        Parse.Promise.when(findAttribValuesQs).then ->
            displayFilters = arguments

            categoryBrands = categoryData.get "supported_brands"

            supported_brands = _.map( categoryBrands, (categoryBrand) ->
                if categoryBrand isnt null
                    brand =
                        "id" : categoryBrand.id
                        "name" : categoryBrand.get("name")

            )


            price_range = categoryData.get "price_range"

            # get all category based products
            ProductItem = Parse.Object.extend("ProductItem")
            
            # query to get specific category
            innerQuery = new Parse.Query("Category")
            innerQuery.equalTo("objectId",categoryId)

            # query to get products matching the child category
            query = new Parse.Query("ProductItem")
            query.matchesQuery("category", innerQuery)

            if (selectedFilters isnt "all") and (_.isObject(selectedFilters))
                filterableProps = Object.keys(selectedFilters)

                if _.contains(filterableProps, "brands")
                    brands = selectedFilters["brands"]

                    if brands.length > 0
                        brandPointers = _.map(brands, (brandId) ->
                          brandPointer = new Parse.Object('Brand')
                          brandPointer.id = brandId
                          brandPointer
                        )                    
            
                        query.containedIn("brand",brandPointers)
                
                if _.contains(filterableProps, "price")
                    price = selectedFilters["price"]

                    if price.length is 2
                        startPrice = parseInt price[0]
                        endPrice = parseInt price[1]
                        
                        query.greaterThanOrEqualTo("mrp", startPrice)
                        query.lessThanOrEqualTo("mrp", endPrice)

                if _.contains(filterableProps, "otherFilters")
                    otherFilters = selectedFilters['otherFilters']

                    if !_.isEmpty(otherFilters)
                        otherFilterColumnNames = _.keys(otherFilters)
                        
                        _.each otherFilterColumnNames , (otherFilterColumnName) ->
                            
                            specificFilterArr = otherFilters[otherFilterColumnName]

                            console.log specificFilterArr

                            if specificFilterArr.length > 0
                                attributeValuePointers = _.map(specificFilterArr, (attributeValueId) ->
                                  attributeValuePointer = new Parse.Object('AttributeValues')
                                  attributeValuePointer.id = attributeValueId
                                  attributeValuePointer
                                  ) 
                
        
                                query.containedIn(otherFilterColumnName,attributeValuePointers)
                    
            # restrict which fields are being returned
            query.select("images,name,mrp,brand,primaryAttributes")

            query.include("brand")
            # query.include("category")
            query.include("primaryAttributes")
            query.include("primaryAttributes.attribute")

            # pagination
            query.limit(displayLimit)
            query.skip(page * displayLimit)

            # sorting
            if ascending is true
                query.ascending(sortBy)
            else
                query.descending(sortBy)

            queryFindPromise =query.find()
            .then (productsList) ->

                products = []

                products = _.map(productsList, (singleProduct) ->
                    
                    brand = 
                        "id" :  singleProduct.get("brand").id
                        "name" :  singleProduct.get("brand").get("name")

                    product = 
                        "objectId" : singleProduct.id
                        "name" : singleProduct.get "name"
                        "brand" : brand
                        "images" : singleProduct.get("images")
                        "mrp" : singleProduct.get("mrp")
                        "primaryAttributes" : singleProduct.get("primaryAttributes") 
                ) 
                
                result =  
                    products: products
                    filters: displayFilters
                    supportedBrands: supported_brands
                    priceRange: price_range
                    sortableAttributes : ["mrp","popularity"]

                response.success result                


            ,(error) ->
                response.error error  

        ,(error) ->
            response.error error            

    ,(error) -> 
        response.error error    

Parse.Cloud.afterSave "ProductItem", (request)->
    productObject = request.object

    stopWords = ["the", "in", "and"]



    toLowerCase = (w) ->
        w.toLowerCase()    

    # pick search keywords from name , model_number , attribute values from attrs , brand name , textAttributes object
    wordsFromName = getWordsFromSentence(productObject.get("name"))
    # wordsFromName = _.map(wordsFromName, toLowerCase)

    # wordsFromName = _.filter(wordsFromName, (w) ->
    #   w.match(/^w+$/) and !_.contains(stopWords, w)
    # )  
    console.log getWordsFromSentence(productObject.get("name"))
    productObject.set "searchKeywords" , wordsFromName
    console.log "Saved keywords as #{wordsFromName}"
    productObject.save()

        
getWordsFromSentence = (sentence) =>

    wordArr = []

    # replace special characters in a sentence with a whitespace
    sentence = sentence.replace(/\W/g, " ")

    # trim sentence to remove leading and trailing white spaces
    sentence = sentence.trim()    

    # split the sentence by white space and retur narray of words
    wordArr = sentence.split(/\s+/g)

    return wordArr



findAttribValues = (filter) =>

    promise = new Parse.Promise()    
                
    filterColumn = filter.get('filterColumn')
    attributeId = filter.get('filterAttribute').id
    attributeName = filter.get('filterAttribute').get("name")

    queryAttributeValues = new Parse.Query("AttributeValues")

    innerAttributeQuery = new Parse.Query("Attributes")
    innerAttributeQuery.equalTo("objectId", attributeId)
    queryAttributeValues.matchesQuery("attribute", innerAttributeQuery)

    queryAttributeValues.find()
    .then (allAttributeValues) ->
        attribValues = _.map(allAttributeValues, (attributeValue) ->
           attribValue =
            "id" : attributeValue.id     
            "name" : attributeValue.get("value")     
        )
        
        displayFilter =
            "filterName": "filter#{filterColumn}"
            "attributeId": attributeId
            "attributeName": attributeName
            "values": attribValues

        promise.resolve displayFilter

    , (error) ->
        promise.reject error

    promise   




