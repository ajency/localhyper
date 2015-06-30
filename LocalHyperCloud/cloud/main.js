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

Parse.Cloud.define("sendSMSCode", function(request, response) {
  var code, onError, phone, query, save;
  phone = request.params.phone;
  code = (Math.floor(Math.random() * 90000) + 10000).toString();
  onError = function(error) {
    return response.error(error);
  };
  save = function(obj, attempts) {
    if (attempts > 3) {
      return response.success({
        attemptsExceeded: true
      });
    } else {
      obj.set({
        'phone': phone,
        'verificationCode': code,
        'attempts': attempts
      });
      return obj.save().then(function() {
        return response.success({
          code: code,
          attemptsExceeded: false
        });
      }, onError);
    }
  };
  query = new Parse.Query('SMSVerify');
  query.equalTo("phone", phone);
  return query.find().then(function(obj) {
    var SMSVerify, attempts, verify;
    if (_.isEmpty(obj)) {
      SMSVerify = Parse.Object.extend("SMSVerify");
      verify = new SMSVerify();
      return save(verify, 1);
    } else {
      obj = obj[0];
      attempts = obj.get('attempts');
      return save(obj, attempts + 1);
    }
  }, onError);
});

Parse.Cloud.define("verifySMSCode", function(request, response) {
  var code, phone, query;
  phone = request.params.phone;
  code = request.params.code;
  query = new Parse.Query('SMSVerify');
  query.equalTo("phone", phone);
  return query.find().then(function(obj) {
    var verificationCode;
    obj = obj[0];
    verificationCode = obj.get('verificationCode');
    if (verificationCode === code) {
      obj.destroy();
      return response.success({
        'verified': true
      });
    } else {
      return response.success({
        'verified': false
      });
    }
  }, function(error) {
    return response.error(error);
  });
});
