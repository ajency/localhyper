angular.module('LocalHyper.auth').controller('VerifyManualCtrl', [
  '$scope', '$rootScope', 'CToast', 'App', 'SmsAPI', 'AuthAPI', 'CSpinner', function($scope, $rootScope, CToast, App, SmsAPI, AuthAPI, CSpinner) {
    var register, requestSMSCode, verifySmsCode;
    $scope.view = {
      display: 'noError'
    };
    $scope.sms = {
      code: '',
      errorAt: ''
    };
    register = function() {
      return AuthAPI.register($rootScope.user).then(function(success) {
        return App.navigate('departments', {}, {
          animate: false,
          back: false
        });
      }, function(error) {
        $scope.sms.errorAt = 'register';
        return $scope.view.display = 'error';
      })["finally"](function() {
        return CSpinner.hide();
      });
    };
    verifySmsCode = function() {
      CSpinner.show('', 'Please wait...');
      return SmsAPI.verifySMSCode($rootScope.user.phone, $scope.sms.code).then(function(data) {
        if (data.verified) {
          return register();
        } else {
          CSpinner.hide();
          return CToast.show('Incorrect verification code');
        }
      }, function(error) {
        CSpinner.hide();
        $scope.sms.errorAt = 'verifySmsCode';
        return $scope.view.display = 'error';
      });
    };
    requestSMSCode = function() {
      CSpinner.show('', 'Please wait...');
      return SmsAPI.requestSMSCode($rootScope.user.phone).then(function(data) {
        if (data.attemptsExceeded) {
          return $scope.view.display = 'maxAttempts';
        }
      }, function(error) {
        $scope.sms.errorAt = 'requestSMSCode';
        return $scope.view.display = 'error';
      })["finally"](function() {
        return CSpinner.hide();
      });
    };
    $scope.onNext = function() {
      var code;
      code = $scope.sms.code;
      if (code === '' || _.isUndefined(code)) {
        return CToast.show('Please enter verification code');
      } else {
        if (App.isOnline()) {
          return verifySmsCode();
        } else {
          return CToast.show('No internet availability');
        }
      }
    };
    $scope.onResendCode = function() {
      return requestSMSCode();
    };
    $scope.$on('$ionicView.enter', function() {
      if (App.isIOS()) {
        return requestSMSCode();
      }
    });
    return $scope.onTryAgain = function() {
      $scope.view.display = 'noError';
      switch ($scope.sms.errorAt) {
        case 'requestSMSCode':
          return requestSMSCode();
        case 'verifySmsCode':
          return verifySmsCode();
        case 'register':
          return register();
      }
    };
  }
]);
