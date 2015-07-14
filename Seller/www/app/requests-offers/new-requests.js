angular.module('LocalHyper.requestsOffers').controller('NewRequestCtrl', [
  '$scope', 'App', 'RequestsAPI', '$rootScope', '$ionicModal', 'Push', function($scope, App, RequestsAPI, $rootScope, $ionicModal, Push) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      requests: [],
      requestIds: [],
      currentRequest: null,
      requestDetails: {
        modal: null,
        details: {}
      },
      init: function() {
        Push.register();
        this.getRequests();
        return this.loadRequestDetails();
      },
      loadRequestDetails: function() {
        return $ionicModal.fromTemplateUrl('views/requests-offers/request-details.html', {
          scope: $scope,
          animation: 'slide-in-up',
          hardwareBackButtonClose: true
        }).then((function(_this) {
          return function(modal) {
            return _this.requestDetails.modal = modal;
          };
        })(this));
      },
      getRequests: function() {
        return RequestsAPI.getNotifications().then((function(_this) {
          return function(requestIds) {
            var notifications;
            _this.requestIds = requestIds;
            notifications = _.size(requestIds);
            if (notifications > 0) {
              App.notification.badge = true;
              App.notification.count = notifications;
            }
            return RequestsAPI.getAll();
          };
        })(this)).then((function(_this) {
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
      isNew: function(requestId) {
        return _.contains(this.requestIds, requestId);
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getRequests();
      },
      showRequestDetails: function(request) {
        console.log(this.currentRequest = request);
        console.log(request.id);
        return this.requestDetails.modal.show();
      }
    };
    $rootScope.$on('on:new:request', function() {
      return $scope.view.getRequests();
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).controller('EachRequestCtrl', [
  '$scope', function($scope) {
    var at, diff, duration, format, hours, hr, iso, min, minutes, now, timeStr;
    iso = $scope.request.createdAt.iso;
    format = 'DD/MM/YYYY HH:mm:ss';
    now = moment().format(format);
    at = moment(iso).format(format);
    diff = moment(now, format).diff(moment(at, format));
    duration = moment.duration(diff);
    minutes = parseInt(duration.asMinutes().toFixed(0));
    hours = parseInt(duration.asHours().toFixed(0));
    if (minutes === 0) {
      timeStr = 'Just now';
    } else if (minutes < 60) {
      min = minutes === 1 ? 'min' : 'mins';
      timeStr = minutes + " " + min + " ago";
    } else {
      hr = hours === 1 ? 'hr' : 'hrs';
      timeStr = hours + " " + hr + " ago";
    }
    return $scope.request.timeStr = timeStr;
  }
]);
