angular.module('LocalHyper.common').factory('UIMsg', [
  function() {
    var UIMsg;
    UIMsg = {
      noInternet: 'No internet available. Please check your network settings',
      serverError: 'Could not connect to server. Please check your network settings'
    };
    return UIMsg;
  }
]);
