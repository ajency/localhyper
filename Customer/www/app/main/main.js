angular.module('LocalHyper.main', []).controller('SideMenuCtrl', [
  '$scope', 'App', '$ionicPopover', function($scope, App, $ionicPopover) {
    return $scope.view = {
      userPopover: null,
      init: function() {
        return this.loadPopOver();
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
      }
    };
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('main', {
      url: '/main',
      abstract: true,
      cache: false,
      templateUrl: 'views/main.html'
    });
  }
]);
