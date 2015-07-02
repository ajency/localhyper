angular.module('LocalHyper.auth').controller('VerifyBeginCtrl', [
  '$scope', '$rootScope', 'App', 'CToast', function($scope, $rootScope, App, CToast) {
    $rootScope.user = {
      name: '',
      phone: ''
    };
    return $scope.onProceed = function() {
      var name, phone, state;
      name = $rootScope.user.name;
      phone = $rootScope.user.phone;
      if (_.contains([name, phone], '') || _.isUndefined(phone)) {
        return CToast.show('Please enter all fields');
      } else {
        if (App.isOnline()) {
          state = App.isAndroid() ? 'verify-auto' : 'verify-manual';
          return App.navigate(state);
        } else {
          return CToast.show('No internet availability');
        }
      }
    };
  }
]);
