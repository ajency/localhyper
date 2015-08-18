getNotificationData = (notificationId, installationId, pushOptions)->
    promise = new Parse.Promise()
    installationQuery = new Parse.Query Parse.Installation
    installationQuery.equalTo "installationId", installationId

    installationQuery.find()
    .then (installationObject)->
        if _.isEmpty(installationObject) then deviceType = 'unknown'
        else deviceType = installationObject[0].get 'deviceType'

        if deviceType.toLowerCase() is 'android'
            pushData = 
                header: pushOptions.title
                message: pushOptions.alert
                data: pushOptions.notificationData

        else
            pushData = 
                title: pushOptions.title
                alert: pushOptions.alert
                data: pushOptions.notificationData
                badge: 'Increment'

        notificationObj = 
            pushData: pushData
            installationId : installationId
            notificationId : notificationId
        
        promise.resolve notificationObj

    , (error)->
        promise.reject error
    
    promise

processPushNotifications = (installationId,pushData,notificationId) ->
    promise = new Parse.Promise()
    
    pushQuery = new Parse.Query Parse.Installation
    pushQuery.equalTo "installationId", installationId  
    
    Parse.Push.send({where: pushQuery, data: pushData})
    .then ->
        # get notification and mark it as processed and update status
        Notification = Parse.Object.extend('Notification')
        query = new Parse.Query(Notification)
        query.equalTo("objectId",notificationId)
        query.first()
        .then (notification) ->
            notification.set "processed", true
            
            notification.save()
            .then (notifobj) ->
                promise.resolve notifobj
            , (error) ->
                promise.reject error
        , (error) ->
            promise.reject error

    , (error) ->
        promise.reject error

    promise


Parse.Cloud.job 'processNotifications', (request, response) ->
    notificationQuery = new Parse.Query("Notification") 

    # get all unporcessed notiifactions
    notificationQuery.equalTo("processed",false)
    notificationQuery.include("recipientUser")
    notificationQuery.include("requestObject")
    notificationQuery.include("requestObject.product")
    notificationQuery.include("offerObject")
    notificationQuery.include("offerObject.request")
    notificationQuery.include("offerObject.request.product")
    notificationQuery.find()
    .then (pendingNotifications) ->
        notificationQs = []
        sellerAppName = "Shopoye Seller"
        customerAppName = "Shopoye"
        # for each pending notifications send get channel of notifications and send take action accordingly
        _.each pendingNotifications, (pendingNotification) ->
            channel = pendingNotification.get "channel"
            
            
            recipientUser = (pendingNotification.get "recipientUser")
            notificationId = pendingNotification.id
            userInstallationId = recipientUser.get("installationId")
            
            type = pendingNotification.get("type")

            if type is "Request"
                obj = pendingNotification.get("requestObject")
                productName = pendingNotification.get("requestObject").get("product").get("name")
                title = sellerAppName
                msg = "New request for #{productName}"
                otherPushData = 
                    "id": obj.id
                    "type": "new_request"
                    "imageUrl" : "https://s3-ap-southeast-1.amazonaws.com/aj-shopoye/images-product/LG%2BLWA5BP1A%2B1.5%2BTon%2B1%2BStar%2BWindow%2BAC(White)-800x480.jpg" #url for product image

            else if type is "Offer"
                obj = pendingNotification.get("offerObject")
                productName = pendingNotification.get("offerObject").get("request").get("product").get("name")
                title = customerAppName
                msg = "New offer for #{productName}"
                otherPushData = 
                    "id":obj.id
                    "type": "new_offer"

            else if type is "AcceptedOffer"
                obj = pendingNotification.get("offerObject")
                productName = pendingNotification.get("offerObject").get("request").get("product").get("name")
                title = sellerAppName
                msg = "Offer accepted for #{productName}"
                otherPushData = 
                    "id":obj.id
                    "type": "accepted_offer"

            else if type is "CancelledRequest"
                obj = pendingNotification.get("requestObject")
                productName = pendingNotification.get("requestObject").get("product").get("name")
                title = sellerAppName
                msg = "Request cancelled for #{productName}"
                otherPushData = 
                    "id":obj.id
                    "type": "cancelled_request"

            else if type is "SentForDeliveryRequest"
                obj = pendingNotification.get("requestObject")
                productName = pendingNotification.get("requestObject").get("product").get("name")
                title = customerAppName
                msg = "#{productName} is sent for delivery"
                otherPushData = 
                    "id":obj.id
                    "type": "request_delivery_changed" 
                    "requestStatus": obj.get "status"

            else if type is "FailedDeliveryRequest"
                obj = pendingNotification.get("requestObject")
                productName = pendingNotification.get("requestObject").get("product").get("name")
                title = customerAppName
                msg = "Delivery failed for #{productName}"
                otherPushData = 
                    "id":obj.id
                    "type": "request_delivery_changed"  
                    "requestStatus": obj.get "status"    

            else if type is "SuccessfulRequest"
                obj = pendingNotification.get("requestObject")
                productName = pendingNotification.get("requestObject").get("product").get("name")
                title = customerAppName
                msg = "Delivery successful for #{productName}"
                otherPushData = 
                    "id":obj.id
                    "type": "request_delivery_changed" 
                    "requestStatus": obj.get "status"                                                        

            switch channel
                when 'push'
                    # add code to push notifcation to the user
                    pushOptions = 
                        title: title
                        alert: msg
                        notificationData: otherPushData 
                                        
                    notificationPromise = getNotificationData notificationId, userInstallationId, pushOptions
                    notificationQs.push notificationPromise

                when 'sms'
                    # add code to send sms to the user
                    console.log "send sms"

        Parse.Promise.when(notificationQs).then ->
            individualPushResults = _.flatten(_.toArray(arguments))
            pushQs = []
            
            _.each individualPushResults , (pushResult) ->
                installationId = pushResult.installationId
                notificationId = pushResult.notificationId
                pushNotifPromise = processPushNotifications(installationId, pushResult.pushData,notificationId)
                pushQs.push pushNotifPromise

            Parse.Promise.when(pushQs).then ->
                response.success("Processed")
            , (error) ->
                response.error (error)

        , (error) ->
            response.error "Error"

        

    , (error) ->
        response.error (error)  

Parse.Cloud.define 'getUnseenNotifications', (request, response) ->
    userId = request.params.userId
    type = request.params.type

    notificationQuery = new Parse.Query("Notification")

    notificationQuery.equalTo("hasSeen",false)

    innerQueryUser = new Parse.Query Parse.User
    innerQueryUser.equalTo("objectId",userId)
    
    notificationQuery.matchesQuery("recipientUser", innerQueryUser)

    notificationQuery.equalTo("type",type)

    notificationQuery.include("requestObject")
    notificationQuery.select("requestObject")
    notificationQuery.select("offerObject")

    notificationQuery.find()
    .then (notificationResults) ->
        unseenNotifications = []
        if type is "Request"
             _.each notificationResults, (notificationObj) ->

                requestObj = notificationObj.get("requestObject")

                currentDate = new Date()
                createdDate = requestObj.createdAt
                diff = currentDate.getTime() - createdDate.getTime()
                differenceInDays =  Math.floor(diff / (1000 * 60 * 60 * 24)) 

                requestStatus = requestObj.get("status")   
                
                if differenceInDays >= 1 
                    if requestStatus is "open"
                        requestStatus = "expired"                              
           
                if requestStatus is "open"
                    requestId = notificationObj.get("requestObject").id
                    unseenNotifications.push requestId     
            
        else if type is "Offer"
            unseenNotifications = _.map(notificationResults, (notificationObj) ->
               requestId = notificationObj.get("offerObject").id     
            )            
        response.success(unseenNotifications)
    , (error) ->
        response.error(error)


Parse.Cloud.define 'updateNotificationStatus', (request, response) ->
    notificationType = request.params.notificationType  # Request / Offer / AcceptedOffer / CancelledRequest
    notificationTypeId = request.params.notificationTypeId # request id / offer id
    recipientId = request.params.recipientId # single recipient id
    hasSeen = request.params.hasSeen
    
    notificationQuery = new Parse.Query("Notification")

    notificationQuery.equalTo("type",notificationType)

    recipientUserObj = 
        "__type" : "Pointer",
        "className":"_User",
        "objectId":recipientId  

    notificationQuery.equalTo("recipientUser", recipientUserObj)
    
    if notificationType is "Request"
        innerQuery = new Parse.Query("Request")
        innerQuery.equalTo("objectId",notificationTypeId)

        notificationQuery.matchesQuery("requestObject", innerQuery)

    else if notificationType is "Offer"
        innerQuery = new Parse.Query("Offer")
        
        if _.isArray(notificationTypeId)
            innerQuery.containedIn("objectId",notificationTypeId)   
                     
        else if _.isString(notificationTypeId) 
            innerQuery.equalTo("objectId",notificationTypeId)


        notificationQuery.matchesQuery("offerObject", innerQuery)

    notificationQuery.find()
    .then (notificationObjects)->
        saveQs = _.map( notificationObjects , (notificationObj) ->
            notificationObj.set("hasSeen",hasSeen)
            notificationObj.save() 
        )
        
        Parse.Promise.when(saveQs).then ->
            updatedNotifications = _.flatten(_.toArray(arguments))   
            response.success (updatedNotifications)
        
        , (error) ->
            response.error error
            
    ,(error) ->
        response.error error







