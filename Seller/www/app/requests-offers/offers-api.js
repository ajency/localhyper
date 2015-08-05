angular.module('LocalHyper.requestsOffers').factory('OffersAPI', [
  '$q', '$http', 'User', function($q, $http, User) {
    var OffersAPI, acceptedOfferId;
    OffersAPI = {};
    acceptedOfferId = '';
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
    OffersAPI.getSellerOffers = function(opts) {
      var defer, params;
      defer = $q.defer();
      params = {
        "sellerId": User.getId(),
        "page": opts.page,
        "displayLimit": opts.displayLimit,
        "acceptedOffers": opts.acceptedOffers,
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
    OffersAPI.acceptedOfferId = function(action, id) {
      switch (action) {
        case 'set':
          return acceptedOfferId = id;
        case 'get':
          return acceptedOfferId;
      }
    };
    return OffersAPI;
  }
]);
