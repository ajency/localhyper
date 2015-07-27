angular.module('LocalHyper.auth').controller('VerifySuccessCtrl', [
  '$scope', 'CToast', 'App', 'SmsAPI', 'AuthAPI', 'CSpinner', 'User', '$ionicPlatform', '$rootScope', '$stateParams', function($scope, CToast, App, SmsAPI, AuthAPI, CSpinner, User, $ionicPlatform, $rootScope, $stateParams) {
    var onDeviceBack;
    $scope.view = {
      onNext: function() {
        var count, goBackPage;
        goBackPage = App.previousState === 'verify-manual' ? -4 : -3;
        count = App.isAndroid() ? goBackPage : -3;
        return App.goBack(count);
      }
    };
    onDeviceBack = function() {
      var count;
      count = App.isAndroid() ? -2 : -1;
      return App.goBack(count);
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      return $scope.view.user = User.info('get');
    });
    $scope.$on('$ionicView.enter', function() {
      $ionicPlatform.onHardwareBackButton(onDeviceBack);
      if (App.isIOS()) {
        return $scope.view.isExistingUser();
      }
    });
    return $scope.$on('$ionicView.leave', function() {
      return $ionicPlatform.offHardwareBackButton(onDeviceBack);
    });
  }
]);
