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
]).factory('OfferHistoryAPI', [
  '$q', '$http', 'User', '$timeout', function($q, $http, User, $timeout) {
    var OfferHistoryAPI;
    OfferHistoryAPI = {};
    OfferHistoryAPI.offerhistory = function(opts) {
      var defer, params, user;
      user = User.getCurrent();
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "sellerId": user.id,
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
    return OfferHistoryAPI;
  }
]);
