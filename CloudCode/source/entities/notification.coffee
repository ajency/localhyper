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
    notificationQuery.include("offerObject")
    notificationQuery.find()
    .then (pendingNotifications) ->
        notificationQs = []
        # for each pending notifications send get channel of notifications and send take action accordingly
        _.each pendingNotifications, (pendingNotification) ->
            channel = pendingNotification.get "channel"
            
            
            recipientUser = (pendingNotification.get "recipientUser")
            notificationId = pendingNotification.id
            userInstallationId = recipientUser.get("installationId")
            
            type = pendingNotification.get("type")

            if type is "Request"
                obj = pendingNotification.get("requestObject")
                msg = "New request for a product"
                otherPushData = 
                    "id": obj.id
                    "type": "new_request"

            else if type is "Offer"
                obj = pendingNotification.get("offerObject")
                msg = "New offer for a product"
                otherPushData = 
                    "id":obj.id
                    "type": "new_offer"

            else if type is "AcceptedOffer"
                obj = pendingNotification.get("offerObject")
                msg = "Offer has been accepted"
                otherPushData = 
                    "id":obj.id
                    "type": "accepted_offer"

            switch channel
                when 'push'
                    # add code to push notifcation to the user
                    pushOptions = 
                        title: 'Shop Oye'
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

    notificationQuery.select("requestObject")

    notificationQuery.find()
    .then (notificationResults) ->
        unseenNotifications = _.map(notificationResults, (notificationObj) ->
           requestId = notificationObj.get("requestObject").id     
        )
        response.success(unseenNotifications)
    , (error) ->
        response.error(error)


Parse.Cloud.define 'updateNotificationStatus', (request, response) ->
    notificationType = request.params.notificationType
    notificationTypeId = request.params.notificationTypeId
    recipientId = request.params.recipientId
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

    notificationQuery.first()
    .then (notificationObj)->
        notificationObj.set("hasSeen",hasSeen)
        notificationObj.save() 
        .then (notif) ->
            response.success (notif)
        , (error) ->
            response.error (error)
    ,(error) ->
        response.error(error)   







