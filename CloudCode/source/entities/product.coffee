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
    queryProductItem.include("attrs.attribute")
    queryProductItem.include("brand")
    queryProductItem.include("category")
    queryProductItem.include("category.secondary_attributes")
    queryProductItem.include("primaryAttributes")
    queryProductItem.include("primaryAttributes.attribute")

    queryProductItem.first()
    .then (ProductData)->
        categoryObj = ProductData.get "category"
        
        category = 
            id : categoryObj.id
            name : categoryObj.get "name"

        brandObj = ProductData.get "brand"

        brand = 
            id : brandObj.id
            name : brandObj.get "name"            

        secondary_attributes = categoryObj.get "secondary_attributes"
        textAttributes = ProductData.get "textAttributes"

        attributeIdNames = {}

        if secondary_attributes.length > 0
            _.each secondary_attributes , (secondary_attribute) ->
                if !_.isNull secondary_attribute
                    if !_.isUndefined secondary_attribute.get "group"
                        group = secondary_attribute.get "group"
                    else 
                        group = "other"

                    if !_.isUndefined secondary_attribute.get "name"
                        name = secondary_attribute.get "name"
                    else 
                        name = ""  
                                      
                    attrobj = 
                        "group" : group
                        "name" : name
                    attributeIdNames[secondary_attribute.id] = attrobj
        

        productAttributes  = ProductData.get "attrs"  

        specifications = [] 

        _.each productAttributes , (productAttributeValue) ->
            attributeObj = productAttributeValue.get "attribute"
            attributeObjId = attributeObj.id

            if !_.isUndefined attributeObj.get "unit"   
                unit = attributeObj.get "unit" 
            else 
                unit = null
            
            productgrp = attributeObj.get "group" 
            productSpec = 
                "group" : productgrp.toLowerCase()           
                "key" : attributeObj.get "name"    
                "value" :  productAttributeValue.get "value"  
                "unit" :  unit

            specifications.push productSpec 


        if !_.isUndefined(textAttributes) or !_.isEmpty(textAttributes)
            for attribId of textAttributes
              if textAttributes.hasOwnProperty(attribId)
                prodgrp = attributeIdNames[attribId]["group"]
                productSpec = 
                    "group" : prodgrp.toLowerCase()           
                    "key" : attributeIdNames[attribId]["name"]     
                    "value" :  textAttributes[attribId]
                    "unit" :  null  
                    
                specifications.push productSpec                     


        productResult =
            id : ProductData.id
            name : ProductData.get "name"
            modelNumber : ProductData.get "model_number"
            mrp : ProductData.get "mrp"
            images : ProductData.get "images"
            category : category
            brand : brand
            primaryAttributes : ProductData.get "primaryAttributes"
            # attributeIdNames : attributeIdNames
            specifications : specifications

        getOtherPricesForProduct(ProductData)
        .then (productPrice) ->  
            productResult["onlinePrice"] = productPrice["online"] 
            productResult["platformPrice"] = productPrice["platform"] 
            
            response.success productResult
        , (error) ->
            response.error error 
    , (error)->
        response.error error    


Parse.Cloud.define 'getProductsNew', (request, response) ->
    categoryId = request.params.categoryId
    selectedFilters = request.params.selectedFilters # "all" / {"brand": "","price": "", "other_filters": [{"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}, {"attribId": "sfd3354", "values": ["dsf455","asdsa34","asd356"]}]} 
    sortBy =  request.params.sortBy
    ascending = request.params.ascending
    page = parseInt request.params.page
    displayLimit = parseInt request.params.displayLimit
    
    if _.has(request.params, 'searchKeywords')
        searchKeywords = request.params.searchKeywords
    else
        searchKeywords = "all"
    

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

            if (searchKeywords isnt "all") and (searchKeywords.length > 0)
                query.containsAll("searchKeywords", searchKeywords)

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

Parse.Cloud.job 'updateCategoryProductsKeywords', (request, response) ->
    categoryId = request.params.categoryId

    innerQueryCategory = new Parse.Query("Category")
    innerQueryCategory.equalTo("objectId", categoryId)

    queryProducts = new Parse.Query("ProductItem")
    queryProducts.matchesQuery("category" , innerQueryCategory)
    queryProducts.include("attrs")
    queryProducts.include("brand")
    queryProducts.include("brand")
    queryProducts.ascending("updatedAt")
    queryProducts.limit(500)
    
    queryProducts.find()
    .then (products) ->
        updateKeywordQs = []
        
        updateKeywordQs = _.map(products , (productObject) ->
            updateProductKeywords(productObject)
        )   

        Parse.Promise.when(updateKeywordQs).then -> 
            response.success "Success"
        , (error) ->
            response.error "Failure"        

    , (error) ->
        response.error "Failure"
 

updateProductKeywords = (productObject) =>
    promise = new Parse.Promise()
    sentenceWithKeyWords = ""

    productName = productObject.get("name")
    sentenceWithKeyWords = sentenceWithKeyWords+" "+productName

    modelNumber = productObject.get("model_number")
    sentenceWithKeyWords = sentenceWithKeyWords+" "+modelNumber

    brandObj = productObject.get("brand")
    brandName = brandObj.get("name")
    sentenceWithKeyWords = sentenceWithKeyWords+" "+brandName

    if !_.isUndefined(productObject.get("textAttributes"))
        textAttributes = productObject.get("textAttributes")
        _.each textAttributes , (textAttribute) ->
            sentenceWithKeyWords = sentenceWithKeyWords+" "+textAttribute

     
    
    if !_.isUndefined(productObject.get("attrs")) 
        productAttrs = productObject.get("attrs")       
        _.each productAttrs , (productAttr) ->
            productAttrValue = productAttr.get("value")
            sentenceWithKeyWords = sentenceWithKeyWords+" "+productAttrValue

    # pick search keywords from name , model_number , attribute values from attrs , brand name , textAttributes object
    wordsFromName = getWordsFromSentence(sentenceWithKeyWords)
    wordsFromName = _.map(wordsFromName, toLowerCase)

    productObject.set "searchKeywords" , wordsFromName

    productObject.save()
    .then (savedProduct) ->
        promise.resolve(savedProduct.id)
    , (error) ->
        promise.reject error


    promise

        
getWordsFromSentence = (sentence) =>

    wordArr = []

    # replace all characters except a-zA-Z0-9 and period in a sentence with a whitespace
    # sentence = sentence.replace(/\W/g, " ")
    sentence = sentence.replace(/[^a-zA-Z0-9.]/g, " ")

    # trim sentence to remove leading and trailing white spaces
    sentence = sentence.trim()    

    # split the sentence by white space and retur narray of words
    wordArr = sentence.split(/\s+/g)

    #  change to lower case
    wordArr = _.map(wordArr, toLowerCase)

    # return only unique words
    wordArr = _.unique(wordArr)

    stopWords = ["the" , "is" , "and"]
    
    words = _.filter(wordArr, (word) ->
      !_.contains(stopWords, word)
    )


    return words

toLowerCase = (w) ->
    w.toLowerCase()        



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

getOtherPricesForProduct = (productObject) ->

    promise = new Parse.Promise()

    productPrice = {}

    productId = productObject.id

    # query Price class 

    queryPrice = new Parse.Query("Price")

    innerQueryProduct = new Parse.Query("ProductItem")
    innerQueryProduct.equalTo("objectId" , productId)

    queryPrice.matchesQuery("product" , innerQueryProduct)
    queryPrice.equalTo("type" , "online_market_price")

    queryPrice.first()
    .then (onlinePriceObj) ->
        if _.isEmpty(onlinePriceObj)
            productPrice["online"] = 
                value : ""
                source : ""
                sourceUrl : ""
                updatedAt : ""
        else
            flipkartUrl = "https://s3-ap-southeast-1.amazonaws.com/aj-shopoye/products+/Flipkart+logo.jpg"
            snapdealUrl = " https://s3-ap-southeast-1.amazonaws.com/aj-shopoye/products+/sd.png"

            if onlinePriceObj.get("source") is "flipkart"
                srcUrl =  flipkartUrl
            else
                srcUrl =  snapdealUrl    
            

            productPrice["online"] = 
                value : onlinePriceObj.get("value")
                source : onlinePriceObj.get("source")
                srcUrl : srcUrl
                updatedAt : onlinePriceObj.updatedAt           
            

        # now find best platform price
        getBestPlatformPrice(productObject)
        .then (platformPrice) ->
            productPrice["platform"] = platformPrice
            promise.resolve productPrice

        , (error) ->
            promise.reject error
    , (error) ->
        promise.reject error

    promise


getBestPlatformPrice = (productObject) ->
    promise = new Parse.Promise()

    # get all prices entered in price table for type other than "open_offer" in price class

    queryPrice = new Parse.Query("Price")
    productId = productObject.id

    innerQueryProduct = new Parse.Query("ProductItem")
    innerQueryProduct.equalTo("objectId" , productId)
    queryPrice.matchesQuery("product",innerQueryProduct)
    queryPrice.notEqualTo("type","online_market_price")

    queryPrice.find()
    .then (platformPrices) ->
        if platformPrices.length is 0 
            minPriceObj =  
                value : ""
                updatedAt : ""
            promise.resolve minPriceObj
        else
            priceValues = []
            priceObjArr = []

            _.each platformPrices , (platformPriceObj) ->
                pricObj = 
                    "value" : parseInt(platformPriceObj.get("value"))
                    "updatedAt" : platformPriceObj.updatedAt   

                priceObjArr.push pricObj

                priceValues.push parseInt(platformPriceObj.get("value"))

            minPrice = _.min(priceValues)

            minPriceObj = _.where priceObjArr, value: minPrice

            promise.resolve minPriceObj[0]


    , (error) ->
        promise.reject error 

    promise


