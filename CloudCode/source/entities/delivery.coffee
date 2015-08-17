Parse.Cloud.define 'testDeliveryDate', (request, response) ->   
    
    claimedDelivery = request.params.claimedDelivery
    offerAcceptedDate = request.params.offerAcceptedDate
    sellerOffDays = request.params.sellerOffDays
    sellerWorkTimings = request.params.sellerWorkTimings

    deliveryDates = getDeliveryDate(claimedDelivery,offerAcceptedDate,sellerOffDays,sellerWorkTimings)
    offerAcceptedDate2 = deliveryDates["offerAcceptedDate"]
    deliveryDate = deliveryDates["deliveryDate"]
    adjustedDeliveryDate = deliveryDates["adjustedDeliveryDate"]

    endWorkTime = sellerWorkTimings[1]
    timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
    
    pendingHours = getHoursDifference(endWorkTime, timeOfDelivery)

    result = 
        moment : moment()
        deliveryDate : moment(deliveryDate).format('dddd DD-MM-YYYY HH:mm:ss')
        adjustedDeliveryDate : moment(adjustedDeliveryDate).format('dddd DD-MM-YYYY HH:mm:ss')
        acceptedDate : moment(offerAcceptedDate).format('dddd DD-MM-YYYY HH:mm:ss')
        offerAcceptedDate2 : deliveryDates["offerAcceptedDate"]
        isDayValidWorking : isValidWorkDay(deliveryDate,sellerOffDays)
        isDayValidWorkTime : isValidWorkTime(deliveryDate,sellerWorkTimings)
        addedDateObject : moment(incrementDateObject(deliveryDate)).format('dddd DD-MM-YYYY HH:mm:ss')
        isTimeBeforeWorkTime : isTimeBeforeWorkTime(deliveryDate,sellerWorkTimings)
        pendingHours : pendingHours
        timeOfDelivery : timeOfDelivery
        endtime : sellerWorkTimings[1]
    response.success result

getDeliveryDate = (claimedDelivery,offerAcceptedDate,sellerOffDays,sellerWorkTimings) ->

    deliveryDuration = claimedDelivery.value
    deliveryUnit = claimedDelivery.unit

    if deliveryUnit is "day"
        deliveryDuration = deliveryDuration * 24
    
    deliveryDate = moment(offerAcceptedDate).add(deliveryDuration ,'hours').toDate()


    pendingHours = ""


   
    adjustedDeliveryDate = fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings,deliveryDuration)

    obj = 
        offerAcceptedDate : offerAcceptedDate
        deliveryDate : deliveryDate
        adjustedDeliveryDate :adjustedDeliveryDate

    return obj

fetchAdjustedDelivery = (offerAcceptedDate, deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration) ->
    # deliveryTime = moment().hour(startTime[0]).minute(startTime[1]).seconds(startTime[2]).add(deliveryDuration, 'hours').format("HH:mm:ss");
    if isValidWorkDay(deliveryDate ,sellerOffDays)
        if _.isEmpty(pendingHours)
            if isValidWorkTime(deliveryDate, sellerWorkTimings)
                console.log "step1"
                
                if(isTimeBeforeWorkTime(offerAcceptedDate, sellerWorkTimings))
                    console.log "step2"
                    startTime = sellerWorkTimings[0]
                    startTime = startTime.split(':')

                    startWorkTime = 
                        "hours" : parseInt startTime[0]
                        "minutes" : parseInt startTime[1]
                        "seconds" : parseInt startTime[2]


                    dDate = deliveryDate
                    acceptDate = offerAcceptedDate
                    modifiedAcceptedDate = moment(acceptDate).hours(startWorkTime["hours"]).minutes(startWorkTime["minutes"]).seconds(startWorkTime["seconds"]).toDate()
                    deliveryDate =  moment(modifiedAcceptedDate).add(deliveryDuration , 'hours').toDate()
                    fetchAdjustedDelivery(modifiedAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
                # if accepted date's time is less than start time of seller then delivery date's time = start_time + deliveryDuration
                # set time of deliveryDate as startWork time
                # to it add deliveryDuration then run the function again
                else
                    console.log "step3"
                    deliveryDate
            else
                console.log "step4"
                if(isTimeBeforeWorkTime(deliveryDate, sellerWorkTimings))
                    console.log "step5"
                    pendingHours = deliveryDuration
                    fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)
                    
                else
                    console.log "step6"
                    # get difference from delivery date's time and end time of work time
                    endWorkTime = sellerWorkTimings[1]
                    timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
                    pendingHours = getHoursDifference(endWorkTime,timeOfDelivery)     # timeOfDelivery > endWorkTime

                    console.log "pending hours#{pendingHours}"

                    deliveryDate = incrementDateObject(deliveryDate)

                    fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings, deliveryDuration)

        else 
            console.log "step7"
            # deliveryDate + startTime + pendingHours
            startWorkTime = sellerWorkTimings[0]
            timeOfDelivery = moment(deliveryDate).format("HH:mm:ss")
            diffInStartAndDelivery = getHoursDifference(timeOfDelivery,startWorkTime)  # startWorkTime > timeOfDelivery

            diffHours = moment(diffInStartAndDelivery, "hh:mm:ss").hours()
            diffMin = moment(diffInStartAndDelivery, "hh:mm:ss").minutes()
            diffSec = moment(diffInStartAndDelivery, "hh:mm:ss").seconds()

            dDate = deliveryDate
            
            moment(dDate).add(diffHours , 'hours')
            moment(dDate).add(diffMin , 'minutes')
            finalMoment = moment(dDate).add(diffSec , 'seconds')

            deliveryDate = finalMoment.toDate()

    else
        console.log "step8"
        deliveryDate = incrementDateObject(deliveryDate)
        deliveryDate = fetchAdjustedDelivery(offerAcceptedDate,deliveryDate, pendingHours, sellerOffDays, sellerWorkTimings,deliveryDuration)


getHoursDifference = (initialTimeString, finalTimeString) ->
    t1 = moment(initialTimeString, "hh:mm:ss")
    t2 = moment(finalTimeString, "hh:mm:ss")
    t3 = moment(t2.diff(t1)).format("hh:mm:ss")  

    return t3 

     
isTimeInRange = (time, range)->
    time = time.split(':')
    timeHour = parseInt time[0]
    timeMin = parseInt time[1]

    startTime = range[0].split(':')
    startTimeHour = parseInt startTime[0]
    startTimeMin = parseInt startTime[1]

    endTime = range[1].split(':')
    endTimeHour = parseInt endTime[0]    
    endTimeMin = parseInt endTime[1]    
    
    if timeHour > startTimeHour and timeHour < endTimeHour
      return true
    else if timeHour is startTimeHour and timeHour < endTimeHour
        if timeMin >= startTimeMin
            return true
        else 
            return false
    else if timeHour > startTimeHour and timeHour is endTimeHour
        if timeMin <= endTimeMin
            return true
        else 
            return false        
    else
      return false


isValidWorkDay = (dateObj,nonWorkDays) ->
    day = moment(dateObj).format('dddd')

    if _.indexOf(nonWorkDays,day) > -1 
        return false 
    else
        return true
 
isValidWorkTime = (dateObj,workTimings) ->

    time = moment(dateObj).format('HH:mm:ss')

    isTimeInRange(time,workTimings)
   

incrementDateObject = (dateObj) ->
    incrementedDateObj = moment(dateObj).add(1 , 'days').toDate()
    return incrementedDateObj

isTimeBeforeWorkTime = (dateObj , workTimings) ->
    time = moment(dateObj).format('HH:mm:ss')
    time = time.split(':')
    timeHour = parseInt time[0]

    startTime = workTimings[0].split(':')
    startTimeHour = parseInt startTime

    endTime = workTimings[1].split(':')
    endTimeHour = parseInt endTime    
    
    if timeHour < startTimeHour 
        obj =
            startTimeHour : startTimeHour
            timeHour : timeHour
        return true
    else
        return false 
