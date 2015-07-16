angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', '$rootScope', '$ionicSideMenuDelegate', function($scope, App, $ionicPopover, $rootScope, $ionicSideMenuDelegate) {
    $scope.view = {
      userPopover: null,
      init: function() {
        this.loadPopOver();
        return $ionicSideMenuDelegate.edgeDragThreshold(true);
      },
      loadPopOver: function() {
        return $ionicPopover.fromTemplateUrl('views/right-popover.html', {
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
    $rootScope.$on('on:new:request', function() {
      return App.notification.increment();
    });
    return $rootScope.$on('on:session:expiry', function() {
      return Parse.User.logOut();
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
