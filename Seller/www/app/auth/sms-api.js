angular.module('LocalHyper.auth').factory('SmsAPI', [
  '$q', '$http', function($q, $http) {
    var SmsAPI;
    SmsAPI = {};
    SmsAPI.requestSMSCode = function(phone) {
      var defer;
      defer = $q.defer();
      $http.post('functions/sendSMSCode', {
        phone: phone
      }).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    SmsAPI.verifySMSCode = function(phone, code) {
      var defer;
      defer = $q.defer();
      $http.post('functions/verifySMSCode', {
        phone: phone,
        code: code
      }).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return SmsAPI;
  }
]);
