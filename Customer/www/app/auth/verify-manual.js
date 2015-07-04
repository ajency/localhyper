angular.module('LocalHyper.auth').controller('VerifyManualCtrl', [
  '$scope', 'CToast', 'App', 'SmsAPI', 'AuthAPI', 'CSpinner', 'User', function($scope, CToast, App, SmsAPI, AuthAPI, CSpinner, User) {
    $scope.view = {
      display: 'noError',
      smsCode: '',
      errorAt: '',
      errorType: '',
      onError: function(type, at) {
        this.display = 'error';
        this.errorType = type;
        return this.errorAt = at;
      },
      requestSMSCode: function() {
        CSpinner.show('', 'Please wait...');
        return SmsAPI.requestSMSCode(this.user.phone).then((function(_this) {
          return function(data) {
            console.log(data);
            if (data.attemptsExceeded) {
              return _this.display = 'maxAttempts';
            }
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error, 'requestSMSCode');
          };
        })(this))["finally"](function() {
          return CSpinner.hide();
        });
      },
      onNext: function() {
        if (this.smsCode === '' || _.isUndefined(this.smsCode)) {
          return CToast.show('Please enter 6 digit verification code');
        } else {
          return this.verifySmsCode();
        }
      },
      verifySmsCode: function() {
        CSpinner.show('', 'Please wait...');
        return SmsAPI.verifySMSCode(this.user.phone, this.smsCode).then((function(_this) {
          return function(data) {
            if (data.verified) {
              return _this.register();
            } else {
              CSpinner.hide();
              return CToast.show('Incorrect verification code');
            }
          };
        })(this), (function(_this) {
          return function(error) {
            CSpinner.hide();
            return _this.onError(error, 'verifySmsCode');
          };
        })(this));
      },
      register: function() {
        return AuthAPI.register(this.user).then(function(success) {
          return App.navigate('categories', {}, {
            animate: false,
            back: false
          });
        }, (function(_this) {
          return function(error) {
            return _this.onError(error, 'register');
          };
        })(this))["finally"](function() {
          return CSpinner.hide();
        });
      },
      onTapToRetry: function() {
        this.display = 'noError';
        switch (this.errorAt) {
          case 'requestSMSCode':
            return this.requestSMSCode();
          case 'verifySmsCode':
            return this.verifySmsCode();
          case 'register':
            return this.register();
        }
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      return $scope.view.user = User.info('get');
    });
    return $scope.$on('$ionicView.enter', function() {
      if (App.isIOS()) {
        return $scope.view.requestSMSCode();
      }
    });
  }
]);
