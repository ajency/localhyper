angular.module('LocalHyper.auth').controller('VerifyBeginCtrl', [
  '$scope', 'App', 'CToast', 'User', 'UIMsg', function($scope, App, CToast, User, UIMsg) {
    return $scope.user = {
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
        var state;
        if (App.isOnline()) {
          User.info('set', $scope.user);
          state = App.isAndroid() ? 'verify-auto' : 'verify-manual';
          return App.navigate(state);
        } else {
          return CToast.show(UIMsg.noInternet);
        }
      }
    };
  }
]);
