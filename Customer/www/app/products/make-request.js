angular.module('LocalHyper.products').controller('MakeRequestCtrl', [
  '$scope', 'App', function($scope, App) {
    $scope.view = {
      a: '',
      logoAndNotif: {
        get: function() {
          this.smallLogo = App.logo.small;
          return this.notifIcon = App.notification.icon;
        },
        reset: function() {
          App.logo.small = this.smallLogo;
          return App.notification.icon = this.notifIcon;
        },
        hide: function() {
          this.get();
          App.logo.small = false;
          return App.notification.icon = false;
        }
      },
      init: function() {}
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      return $scope.view.logoAndNotif.hide();
    });
    return $scope.$on('$ionicView.beforeLeave', function() {
      return $scope.view.logoAndNotif.reset();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('make-request', {
      url: '/make-request',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/make-request.html',
          controller: 'MakeRequestCtrl'
        }
      }
    });
  }
]);
