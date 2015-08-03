angular.module('LocalHyper.auth').controller('VerifySuccessCtrl', [
  '$scope', 'App', '$ionicPlatform', function($scope, App, $ionicPlatform) {
    $scope.goBack = function() {
      var count, forAndroid, forIOS;
      forAndroid = App.previousState === 'verify-manual' ? -4 : -3;
      forIOS = -3;
      count = App.isAndroid() ? forAndroid : forIOS;
      return App.goBack(count);
    };
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton($scope.goBack);
    });
    return $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton($scope.goBack);
    });
  }
]);
