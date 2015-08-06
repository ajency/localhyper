angular.module('LocalHyper.auth').controller('VerifySuccessCtrl', [
  '$scope', 'App', '$ionicPlatform', function($scope, App, $ionicPlatform) {
    $scope.onProceed = function() {
      return App.navigate('new-requests', {}, {
        animate: true,
        back: false
      });
    };
    $scope.$on('$ionicView.enter', function() {
      return $ionicPlatform.onHardwareBackButton($scope.onProceed);
    });
    return $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton($scope.onProceed);
    });
  }
]);
