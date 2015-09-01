angular.module('LocalHyper.common').directive('ajError', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'views/common/error.html',
      scope: {
        tapToRetry: '&',
        errorType: '='
      },
      link: function(scope, el, attr) {
        var errorMsg;
        switch (scope.errorType) {
          case 'offline':
            errorMsg = 'No internet availability';
            break;
          case 'server_error':
            errorMsg = 'Could not connect to server';
            break;
          case 'session_expired':
            errorMsg = 'Your session has expired';
            break;
          default:
            errorMsg = 'Unknown error';
        }
        scope.errorMsg = errorMsg;
        return scope.onTryAgain = function() {
          return scope.tapToRetry();
        };
      }
    };
  }
]);
