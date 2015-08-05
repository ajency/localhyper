angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', 'CSpinner', '$timeout', 'Push', 'User', 'RequestsAPI', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate, CSpinner, $timeout, Push, User, RequestsAPI) {
    $scope.view = {
      userPopover: null,
      init: function() {
        Push.register();
        this.loadPopOver();
        if (User.isLoggedIn()) {
          this.getNotifications();
        }
        return $ionicSideMenuDelegate.edgeDragThreshold(true);
      },
      getNotifications: function() {
        return RequestsAPI.getNotifications().then((function(_this) {
          return function(requestIds) {
            var notifications;
            notifications = _.size(requestIds);
            if (notifications > 0) {
              App.notification.badge = true;
              return App.notification.count = notifications;
            }
          };
        })(this));
      },
      loadPopOver: function() {
        return $ionicPopover.fromTemplateUrl('views/user-popover.html', {
          scope: $scope
        }).then((function(_this) {
          return function(popover) {
            return _this.userPopover = popover;
          };
        })(this));
      },
      onBackClick: function() {
        var count;
        if (App.currentState === 'verify-manual') {
          count = App.isAndroid() ? -2 : -1;
        } else {
          count = -1;
        }
        return App.goBack(count);
      },
      menuClose: function() {
        return $ionicSideMenuDelegate.toggleLeft();
      }
    };
    $rootScope.$on('$user:registration:success', function() {
      App.notification.icon = true;
      return $scope.view.getNotifications();
    });
    $rootScope.$on('get:unseen:notifications', function(e, obj) {
      return $scope.view.getNotifications();
    });
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_request') {
        if (App.notification.count === 0) {
          return $scope.view.getNotifications();
        } else {
          return App.notification.increment();
        }
      }
    });
    return $rootScope.$on('on:session:expiry', function() {
      CSpinner.show('', 'Your session has expired, please wait...');
      return $timeout(function() {
        Parse.User.logOut();
        App.notification.icon = false;
        App.notification.badge = false;
        App.navigate('business-details', {}, {
          animate: true,
          back: false
        });
        return CSpinner.hide();
      }, 2000);
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      templateUrl: 'views/main.html'
    });
  }
]);
