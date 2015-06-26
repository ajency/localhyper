angular.module('LocalHyper.auth').controller('SignUpCtrl', [
  '$scope', 'AuthAPI', function($scope, AuthAPI) {
    $scope.signUp = {
      name: 'Deepak',
      phone: '9765436351'
    };
    return $scope.onSignUp = function() {
      return AuthAPI.register($scope.signUp).then(function(success) {
        return console.log(success);
      }, function(error) {
        return console.log(error);
      });
    };
  }
]);
