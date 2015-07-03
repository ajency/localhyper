angular.module('LocalHyper.common').factory('Network', [
  '$q', '$cordovaNetwork', function($q, $cordovaNetwork) {
    var Network, isOnline, isValidUrl;
    Network = {};
    isOnline = function() {
      if (ionis.Platform.isWebView()) {
        return $cordovaNetwork.isOnline();
      } else {
        return navigator.onLine;
      }
    };
    isValidUrl = function(config) {
      if (s.contains(config.url, '.html')) {
        return false;
      } else {
        return true;
      }
    };
    Network.request = function(config) {
      if (isValidUrl(config)) {
        if (isOnline()) {
          return config;
        } else {
          return $q.reject('no-internet');
        }
      } else {
        return config;
      }
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
