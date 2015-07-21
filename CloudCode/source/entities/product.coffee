Parse.Cloud.job 'productImport', (request, response) ->
    ProductItem = Parse.Object.extend('ProductItem')

    productSavedArr = []

    products =  request.params.products

    categoryId = request.params.categoryId

    # get category data
    queryCategory = new Parse.Query("Category")

    queryCategory.equalTo("objectId", categoryId)

    queryCategory.include("filterable_attributes")
    queryCategory.include("filterable_attributes.filterAttribute")
    queryCategory.include("primary_attributes")
    queryCategory.select("filterable_attributes","primary_attributes")    

    queryCategory.first()

    .then (categoryObj) ->
        _.each products, (product) -> 
            productItem = new ProductItem()

            if product.objectId isnt ""
                productItem.id = product.objectId

            productAttributes = product.attrs

            # set direct columns of product item
            productItem.set "name", product.name
            productItem.set "images", product.images
            productItem.set "model_number", product.model_number
            productItem.set "mrp", parseInt product.mrp
            productItem.set "popularity", product.popularity
            productItem.set "group", product.group 

            # set product brand
            brandObj =
                "__type" : "Pointer",
                "className":"Brand",
                "objectId":product.brandId                    

            productItem.set "brand", brandObj        

            productItem.set "category", categoryObj 


            # get primary attribute from category and set that as primary attribute column 
            categoryPrimaryAttribute = categoryObj.get("primary_attributes")
            
            if !_.isUndefined(categoryPrimaryAttribute)
                primeAttrib =_.first(categoryPrimaryAttribute)
                primaryAttributeValueArr = []
                primaryAttribObj = 
                    "__type" : "Pointer",
                    "className":"AttributeValues",
                    "objectId":primeAttrib.id
                    
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
                console.log attrib
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
            response.success "Successfully added the products"
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

    queryProductItem.first()
    .then (ProductData)->
        response.success ProductData
    , (error)->
        response.error error    





    




