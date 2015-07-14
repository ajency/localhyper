angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', function($scope, App, RequestsAPI) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      init: function() {
        return this.getRequests();
      },
      getRequests: function() {
        return RequestsAPI.getAll().then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function(data) {
        this.display = 'noError';
        return this.requests = data.requests;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getRequests();
      }
    };
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]);
