var $q, _, getPushData;

$q = require('cloud/lib/q.js');

_ = require('underscore');

Parse.Cloud.useMasterKey();

getPushData = function(installationId, pushOptions) {
  var defer, installationQuery;
  defer = $q.defer();
  installationQuery = new Parse.Query(Parse.Installation);
  installationQuery.equalTo("installationId", installationId);
  installationQuery.find().then(function(installationObject) {
    var deviceType, pushData;
    if (_.isEmpty(installationObject)) {
      deviceType = 'unknown';
    } else {
      deviceType = installationObject[0].get('deviceType');
    }
    if (deviceType.toLowerCase() === 'android') {
      pushData = {
        header: pushOptions.title,
        message: pushOptions.alert,
        request: pushOptions.request
      };
    } else {
      pushData = {
        title: pushOptions.title,
        alert: pushOptions.alert,
        request: pushOptions.request,
        badge: 'Increment'
      };
    }
    return defer.resolve(pushData);
  }, function(error) {
    return defer.reject(error);
  });
  return defer.promise;
};

Parse.Cloud.define("addOffers", function(request, response) {
  var Offers, deliveryTime, installationId, location, offers, price, req;
  location = request.params.location.toString();
  price = request.params.price.toString();
  deliveryTime = request.params.deliveryTime.toString();
  installationId = request.params.installationId.toString();
  req = request.params.request.toString();
  Offers = Parse.Object.extend("Offers");
  offers = new Offers();
  offers.set({
    'location': location,
    'price': price,
    'deliveryTime': deliveryTime,
    'request': req
  });
  return offers.save().then(function(obj) {
    var pushOptions, pushQuery;
    pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("installationId", installationId);
    pushOptions = {
      title: 'LocalHyper',
      alert: 'New offer available',
      request: obj.get('request')
    };
    return getPushData(installationId, pushOptions).then(function(pushData) {
      return Parse.Push.send({
        where: pushQuery,
        data: pushData
      }).then(function() {
        return response.success("SUCCESS: Saved new offer and sent push");
      }, function(error) {
        return response.error("ERROR: Could not send push");
      });
    }, function(error) {
      return response.error('ERROR: Could not get push data');
    });
  }, function(object, error) {
    return response.error("ERROR: Could not save offer");
  });
});
