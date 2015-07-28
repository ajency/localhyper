angular.module('LocalHyper.auth').controller('VerifySuccessCtrl', [
  '$scope', 'CToast', 'App', 'CSpinner', 'User', '$ionicPlatform', '$rootScope', 'Storage', function($scope, CToast, App, CSpinner, User, $ionicPlatform, $rootScope, Storage) {
    return $scope.view = {
      onProceed: function() {
        Storage.bussinessDetails('remove');
        Storage.categoryChains('remove');
        return App.navigate('new-requests', {}, {
          animate: true,
          back: false
        });
      }
    };
  }
]);
