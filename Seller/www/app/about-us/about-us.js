angular.module('LocalHyper.aboutUs', []).controller('AboutUsCtrl', [
  '$scope', '$cordovaAppVersion', 'App', function($scope, $cordovaAppVersion, App) {
    $scope.view = {
      appVersion: 'Loading...',
      init: function() {
        if (App.isWebView()) {
          return $cordovaAppVersion.getAppVersion().then((function(_this) {
            return function(version) {
              return _this.appVersion = version;
            };
          })(this));
        }
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function(event, viewData) {
      if (!viewData.enableBack) {
        return viewData.enableBack = true;
      }
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('about-us', {
      url: '/about-us',
      parent: 'main',
      cache: false,
      views: {
        "appContent": {
          controller: 'AboutUsCtrl',
          templateUrl: 'views/about-us.html'
        }
      }
    });
  }
]);
