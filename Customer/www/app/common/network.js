angular.module('LocalHyper.common').factory('Network', [
  '$q', '$cordovaNetwork', '$rootScope', function($q, $cordovaNetwork, $rootScope) {
    var Network, isHttpUrl;
    Network = {};
    isHttpUrl = function(url) {
      if (s.contains(url, '.html')) {
        return false;
      } else {
        return true;
      }
    };
    Network.request = function(config) {
      var token, url;
      url = config.url;
      if (isHttpUrl(url)) {
        if ($rootScope.App.isOnline()) {
          config.url = "https://api.parse.com/1/functions/" + url;
          if ($rootScope.App.isLoggedIn()) {
            token = $rootScope.App.getSessionToken();
            config.headers['X-Parse-Session-Token'] = token;
          }
          return config;
        } else {
          return $q.reject('offline');
        }
      } else {
        return config;
      }
    };
    Network.responseError = function(rejection) {
      if (_.has(rejection, 'data')) {
        if (_.isNull(rejection.data)) {
          rejection = 'server_error';
        } else if (rejection.data.code === Parse.Error.INVALID_SESSION_TOKEN) {
          rejection = "session_expired";
        }
      }
      return $q.reject(rejection);
    };
    return Network;
  }
]).config([
  '$httpProvider', function($httpProvider) {
    $httpProvider.defaults.headers.post['Content-Type'] = 'application/json';
    $httpProvider.defaults.headers.common['X-Parse-Application-Id'] = APP_ID;
    $httpProvider.defaults.headers.common['X-Parse-REST-API-Key'] = REST_API_KEY;
    return $httpProvider.interceptors.push('Network');
  }
]);
