angular.module('LocalHyper.requestsOffers').factory('OffersAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
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
    OffersAPI.offerhistory = function(opts) {
      var defer, params;
      defer = $q.defer();
      params = {
        "sellerId": User.getId(),
        "page": opts.page,
        "displayLimit": "3",
        "acceptedOffers": false,
        "selectedFilters": [],
        "sortBy": "updatedAt",
        "descending": true
      };
      $http.post('functions/getSellerOffers', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return OffersAPI;
  }
]);
