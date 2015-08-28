Parse.Cloud.define 'testDeliveryDate', (request, response) ->   
    
    claimedDelivery = request.params.claimedDelivery
    deliveryDurationInDays = parseInt claimedDelivery.value
    acceptedDateIST = request.params.acceptedDateIST
    sellerOffDays = request.params.sellerOffDays

    deliveryDate = getDeliveryDate(acceptedDateIST,sellerOffDays,deliveryDurationInDays)

    result = 
        moment : moment()
        deliveryDate : deliveryDate
        acceptedDateIST : acceptedDateIST
        isValidWorkDay : isValidWorkDay(acceptedDateIST ,sellerOffDays)
        isTimeBeforeWorkTime : isTimeBeforeWorkTime(acceptedDateIST, "14:00:00")

    response.success result

incrementDateObject = (dateObj) ->
    incrementedDateObj = moment(dateObj).add(1 , 'days').toDate()
    return incrementedDateObj

isTimeBeforeWorkTime = (dateObj , endWorkTime) ->
    time = moment(dateObj).format('HH:mm:ss')
    time = time.split(':')
    timeHour = parseInt time[0]
    timeMin = parseInt time[1] 


    endTime = endWorkTime.split(':')
    endTimeHour = parseInt endTime[0]    
       
    
    if timeHour < endTimeHour
        return true
    else if timeHour is endTimeHour
        if timeMin > 0
            return false
        else
            return true
    else
        return false

isValidWorkDay = (dateObj,nonWorkDays) ->
    day = moment(dateObj).format('dddd')

    if _.indexOf(nonWorkDays,day) > -1 
        return false 
    else
        return true


getDeliveryDate = (accpetedDateIST,sellerOffDays,deliveryDurationInDays) ->

    incrementDayFlag = false
    pendingDays = 0
    newAcceptedDate = accpetedDateIST

    deliveryDate = fetchAdjustedDelivery(newAcceptedDate,deliveryDurationInDays, sellerOffDays, incrementDayFlag, pendingDays)
    deliveryDate


fetchAdjustedDelivery = (newAcceptedDate,deliveryDurationInDays, sellerOffDays, incrementDayFlag, pendingDays) ->
    if isValidWorkDay(newAcceptedDate ,sellerOffDays)
        endWorkTime = "14:00:00"
        if deliveryDurationInDays is 0  and incrementDayFlag is false 
            if isTimeBeforeWorkTime(newAcceptedDate, endWorkTime)
                pendingDays = 0
                
            else 
                pendingDays = 1
                
        else
            pendingDays = deliveryDurationInDays

        deliveryDate = moment(newAcceptedDate).add(pendingDays , "days").toDate()
    else
        incrementDayFlag = true
        newAcceptedDate = incrementDateObject(newAcceptedDate)
        deliveryDate = fetchAdjustedDelivery(newAcceptedDate,deliveryDurationInDays, sellerOffDays, incrementDayFlag, pendingDays)




# fetchAdjustedDelivery = (offerAcceptedDate, deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration) ->
#     # deliveryTime = moment().hour(startTime[0]).minute(startTime[1]).seconds(startTime[2]).add(deliveryDuration, 'hours').format("HH:mm:ss");
#     if isValidWorkDay(deliveryDate ,sellerOffDays)
#         if _.isEmpty(pendingHours)
#             if isValidWorkTime(deliveryDate, sellerWorkTimings)
#                 console.log "step1"
                
#                 if(isTimeBeforeWorkTime(offerAcceptedDate, sellerWorkTimings))
#                     console.log "step2"
#                     startTime = sellerWorkTimings[0]
#                     startTime = startTime.split(':')

#                     startWorkTime = 
#                         "hours" : parseInt startTime[0]
#                         "minutes" : parseInt startTime[1]
#                         "seconds" : parseInt startTime[2]


#                     dDate = deliveryDate
#                     acceptDate = offerAcceptedDate
#                     modifiedAcceptedDate = moment(acceptDate).hours(startWorkTime["hours"]).minutes(startWorkTime["minutes"]).seconds(startWorkTime["seconds"]).toDate()
#                     deliveryDate =  moment(modifiedAcceptedDate).add(deliveryDuration , 'hours').toDate()
#                     fetchAdjustedDelivery(modifiedAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
#                 # if accepted date's time is less than start time of seller then delivery date's time = start_time + deliveryDuration
#                 # set time of deliveryDate as startWork time
#                 # to it add deliveryDuration then run the function again
#                 else
#                     console.log "step3"
#                     deliveryDate
#             else
#                 console.log "step4"
#                 if(isTimeBeforeWorkTime(deliveryDate, sellerWorkTimings))
#                     console.log "step5"
#                     pendingHours = deliveryDuration
#                     fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
                    
#                 else
#                     console.log "step6"
#                     # get difference from delivery date's time and end time of work time
#                     endWorkTime = sellerWorkTimings[1]
#                     timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
#                     pendingHours = getHoursDifference(endWorkTime,timeOfDelivery)     # timeOfDelivery > endWorkTime

#                     console.log "pending hours#{pendingHours}"

#                     deliveryDate = incrementDateObject(deliveryDate)

#                     fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)

#         else 
#             console.log "step7"
#             # deliveryDate + startTime + pendingHours
#             startWorkTime = sellerWorkTimings[0]
#             timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
#             diffInStartAndDelivery = getHoursDifference(timeOfDelivery,startWorkTime)  # startWorkTime > timeOfDelivery

#             diffHours = moment(diffInStartAndDelivery, "hh:mm:ss").hours()
#             diffMin = moment(diffInStartAndDelivery, "hh:mm:ss").minutes()
#             diffSec = moment(diffInStartAndDelivery, "hh:mm:ss").seconds()

#             dDate = deliveryDate
            
#             moment(dDate).add(diffHours , 'hours')
#             moment(dDate).add(diffMin , 'minutes')
#             finalMoment = moment(dDate).add(diffSec , 'seconds')

#             deliveryDate = finalMoment.toDate()

#     else
#         console.log "step8"
#         deliveryDate = incrementDateObject(deliveryDate)
#         deliveryDate = fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings,deliveryDuration)


# getHoursDifference = (initialTimeString, finalTimeString) ->
#     t1 = moment(initialTimeString, "hh:mm:ss")
#     t2 = moment(finalTimeString, "hh:mm:ss")
#     t3 = moment(t2.diff(t1)).format("hh:mm:ss")  

#     return t3 

     
# isTimeInRange = (time, range)->
#     time = time.split(':')
#     timeHour = parseInt time[0]
#     timeMin = parseInt time[1]

#     startTime = range[0].split(':')
#     startTimeHour = parseInt startTime[0]
#     startTimeMin = parseInt startTime[1]

#     endTime = range[1].split(':')
#     endTimeHour = parseInt endTime[0]    
#     endTimeMin = parseInt endTime[1]    
    
#     if timeHour > startTimeHour and timeHour < endTimeHour
#       return true
#     else if timeHour is startTimeHour and timeHour < endTimeHour
#         if timeMin >= startTimeMin
#             return true
#         else 
#             return false
#     else if timeHour > startTimeHour and timeHour is endTimeHour
#         if timeMin <= endTimeMin
#             return true
#         else 
#             return false        
#     else
#       return false

# isValidWorkTime = (dateObj,workTimings) ->

#     time = moment(dateObj).format('HH:mm:ss')

#     isTimeInRange(time,workTimings)
   

