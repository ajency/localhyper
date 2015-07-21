angular.module('LocalHyper.requestsOffers').factory('OfferHistoryAPI', [
  '$q', '$http', 'User', '$timeout', function($q, $http, User, $timeout) {
    var OfferHistoryAPI;
    OfferHistoryAPI = {};
    OfferHistoryAPI.offerhistory = function(opts) {
      var defer, params, user;
      user = User.getCurrent();
      console.log('userid' + user.id);
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "sellerId": user.id,
        "page": opts.page,
        "displayLimit": "10"
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
