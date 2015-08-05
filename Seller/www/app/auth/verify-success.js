angular.module('LocalHyper.auth').controller('VerifySuccessCtrl', [
  '$scope', 'CToast', 'App', 'CSpinner', 'User', '$ionicPlatform', '$rootScope', 'Storage', function($scope, CToast, App, CSpinner, User, $ionicPlatform, $rootScope, Storage) {
    $scope.onProceed = function() {
      return App.navigate('new-requests', {}, {
        animate: true,
        back: false
      });
    };
    $scope.$on('$ionicView.enter', function() {});
    $ionicPlatform.onHardwareBackButton($scope.onProceed);
    $scope.$on('$ionicView.leave', function() {});
    return $ionicPlatform.offHardwareBackButton($scope.onProceed);
  }
]);
