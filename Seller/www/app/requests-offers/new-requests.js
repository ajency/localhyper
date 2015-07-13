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
      },
      createdAt: function(at) {
        var diff, duration, format, now;
        format = 'DD/MM/YYYY hh:mm';
        now = moment().format(format);
        at = moment(at).format(format);
        diff = moment(at, format).diff(moment(now, format));
        duration = moment.duration(diff);
        return parseInt(duration.asHours());
      }
    };
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]);
