angular.module('LocalHyper.requestsOffers').factory('OffersAPI', [
  '$q', '$http', function($q, $http) {
    var OffersAPI;
    OffersAPI = {};
    OffersAPI.makeOffer = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/makeOffer', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return OffersAPI;
  }
]);
