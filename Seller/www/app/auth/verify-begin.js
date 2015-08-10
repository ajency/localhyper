angular.module('LocalHyper.auth').controller('VerifyBeginCtrl', [
  '$scope', 'App', 'CToast', 'User', 'UIMsg', 'Storage', function($scope, App, CToast, User, UIMsg, Storage) {
    $scope.user = {
      name: '',
      phone: '',
      setDetails: function() {
        var userInfo;
        userInfo = User.info('get');
        this.name = userInfo.name;
        return this.phone = userInfo.phone;
      },
      onProceed: function() {
        if (_.contains([this.name, this.phone], '')) {
          return CToast.show('Fill up all fields');
        } else if (_.isUndefined(this.phone)) {
          return CToast.show('Enter valid phone number');
        } else {
          return this.nextStep();
        }
      },
      nextStep: function() {
        if (App.isOnline()) {
          return Storage.bussinessDetails('get').then((function(_this) {
            return function(details) {
              details['phone'] = _this.phone;
              details['name'] = _this.name;
              return Storage.bussinessDetails('set', details).then(function() {
                var state;
                User.info('set', $scope.user);
                state = App.isAndroid() ? 'verify-auto' : 'verify-manual';
                return App.navigate(state);
              });
            };
          })(this));
        } else {
          return CToast.show(UIMsg.noInternet);
        }
      }
    };
    return $scope.$on('$ionicView.beforeEnter', function() {
      return $scope.user.setDetails();
    });
  }
]);
