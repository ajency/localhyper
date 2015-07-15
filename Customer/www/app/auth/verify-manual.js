angular.module('LocalHyper.auth').controller('VerifyManualCtrl', [
  '$scope', 'CToast', 'App', 'SmsAPI', 'AuthAPI', 'CSpinner', 'User', '$ionicPlatform', function($scope, CToast, App, SmsAPI, AuthAPI, CSpinner, User, $ionicPlatform) {
    var onDeviceBack;
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
      isExistingUser: function() {
        return AuthAPI.isExistingUser(this.user).then((function(_this) {
          return function(data) {
            var count;
            if (data.existing) {
              if (data.userObj[0].get('userType') === 'seller') {
                count = App.isAndroid() ? -2 : -1;
                App.goBack(count);
                return CToast.show('Sorry, you are already a registered seller');
              } else {
                return _this.requestSMSCode();
              }
            } else {
              return _this.requestSMSCode();
            }
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error, 'isExistingUser');
          };
        })(this));
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
          var count;
          count = App.isAndroid() ? -3 : -2;
          return App.goBack(count);
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
          case 'isExistingUser':
            return this.isExistingUser();
          case 'requestSMSCode':
            return this.requestSMSCode();
          case 'verifySmsCode':
            return this.verifySmsCode();
          case 'register':
            return this.register();
        }
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