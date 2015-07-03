angular.module('LocalHyper.common').factory('Network', [
  '$q', '$cordovaNetwork', function($q, $cordovaNetwork) {
    var Network, isHttpUrl, isOnline;
    Network = {};
    isOnline = function() {
      if (ionis.Platform.isWebView()) {
        return $cordovaNetwork.isOnline();
      } else {
        return navigator.onLine;
      }
    };
    isHttpUrl = function(config) {
      if (s.contains(config.url, '.html')) {
        return false;
      } else {
        return true;
      }
    };
    Network.request = function(config) {
      if (isHttpUrl(config)) {
        if (isOnline()) {
          return config;
        } else {
          return $q.reject('offline');
        }
      } else {
        return config;
      }
    };
    Network.responseError = function(rejection) {
      return $q.reject(rejection);
    };
    return Network;
  }
]).config([
  '$httpProvider', function($httpProvider) {
    var contentType;
    contentType = 'application/x-www-form-urlencoded; charset=UTF-8';
    $httpProvider.defaults.headers.common['Content-Type'] = contentType;
    $httpProvider.defaults.headers.post['Content-Type'] = contentType;
    return $httpProvider.interceptors.push('Network');
  }
]);
