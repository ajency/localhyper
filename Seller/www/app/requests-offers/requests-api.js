angular.module('LocalHyper.requestsOffers').factory('RequestsAPI', [
  '$q', '$http', 'User', '$timeout', function($q, $http, User, $timeout) {
    var RequestsAPI, cancelledRequestId;
    RequestsAPI = {};
    cancelledRequestId = '';
    RequestsAPI.getAll = function(opts) {
      var defer, params, user;
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "sellerId": user.id,
        "city": user.get('city'),
        "area": user.get('area'),
        "sellerLocation": "default",
        "sellerRadius": opts.sellerRadius,
        "categories": opts.categories,
        "brands": opts.brands,
        "productMrp": opts.productMrp
      };
      $http.post('functions/getNewRequests', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestsAPI.getSingleRequest = function(requestId) {
      var defer, params, user;
      defer = $q.defer();
      user = User.getCurrent();
      params = {
        "requestId": requestId,
        "sellerId": user.id,
        "sellerGeoPoint": user.get('addressGeoPoint')
      };
      $http.post('functions/getSingleRequest', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestsAPI.getNotifications = function() {
      var defer, params;
      defer = $q.defer();
      params = {
        "userId": User.getId(),
        "type": "Request"
      };
      $http.post('functions/getUnseenNotifications', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestsAPI.updateNotificationStatus = function(requestId) {
      var defer, params;
      defer = $q.defer();
      params = {
        "notificationTypeId": requestId,
        "recipientId": User.getId(),
        "notificationType": "Request",
        "hasSeen": true
      };
      $http.post('functions/updateNotificationStatus', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestsAPI.updateRequestStatus = function(params) {
      var defer;
      defer = $q.defer();
      $http.post('functions/updateRequestStatus', params).then(function(data) {
        return defer.resolve(data.data.result);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    RequestsAPI.cancelledRequestId = function(action, id) {
      switch (action) {
        case 'set':
          return cancelledRequestId = id;
        case 'get':
          return cancelledRequestId;
      }
    };
    return RequestsAPI;
  }
]);
