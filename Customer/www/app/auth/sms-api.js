angular.module('LocalHyper.auth').factory('SmsAPI', [
  '$q', 'App', function($q, App) {
    var SmsAPI;
    SmsAPI = {};
    SmsAPI.requestSMSCode = function(phone) {
      var defer;
      defer = $q.defer();
      Parse.Cloud.run('sendSMSCode', {
        phone: phone
      }).then(function(data) {
        return defer.resolve(data);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    SmsAPI.verifySMSCode = function(phone, code) {
      var defer;
      defer = $q.defer();
      Parse.Cloud.run('verifySMSCode', {
        phone: phone,
        code: code
      }).then(function(data) {
        return defer.resolve(data);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return SmsAPI;
  }
]);
