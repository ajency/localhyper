angular.module('LocalHyper.auth').controller('RegisterCtrl', [
  '$scope', 'AuthAPI', 'App', 'CSpinner', 'SmsAPI', 'CSms', function($scope, AuthAPI, App, CSpinner, SmsAPI, CSms) {
    var handleForPlatform, showPlatformSpinner;
    $scope.register = {
      name: 'Deepak',
      phone: 9765436351,
      maxAttempts: false
    };
    showPlatformSpinner = function() {
      if (App.isAndroid()) {
        return CSpinner.show('Waiting for verification code', 'Please do not close the app...');
      } else if (App.isIOS()) {
        return CSpinner.show('Sending verification code', 'Please wait...');
      }
    };
    handleForPlatform = function() {};
    return $scope.requestSMSCode = function() {
      if (App.isOnline()) {
        showPlatformSpinner();
        return SmsAPI.requestSMSCode($scope.register.phone).then(function(data) {
          if (data.attemptsExceeded) {
            return $scope.register.maxAttempts = true;
          } else {
            return handleForPlatform();
          }
        }, function(error) {
          console.log('onError');
          console.log(error);
          return CSpinner.hide();
        });
      }
    };
  }
]);
