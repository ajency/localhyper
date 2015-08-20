angular.module('LocalHyper.googleMaps').factory('GPS', [
  '$q', '$cordovaGeolocation', 'App', function($q, $cordovaGeolocation, App) {
    var GPS;
    GPS = {};
    GPS.isLocationEnabled = function() {
      var defer;
      defer = $q.defer();
      if (App.isWebView()) {
        cordova.plugins.diagnostic.isLocationEnabled(function(enabled) {
          return defer.resolve(enabled);
        }, function(error) {
          return defer.reject(error);
        });
      } else {
        defer.resolve(true);
      }
      return defer.promise;
    };
    GPS.switchToLocationSettings = function() {
      if (App.isWebView() && App.isAndroid()) {
        return cordova.plugins.diagnostic.switchToLocationSettings();
      }
    };
    GPS.getCurrentLocation = function() {
      var defer, posOptions;
      defer = $q.defer();
      posOptions = {
        maximumAge: 0,
        timeout: 15000,
        enableHighAccuracy: true
      };
      $cordovaGeolocation.getCurrentPosition(posOptions).then(function(position) {
        var loc;
        loc = {
          lat: position.coords.latitude,
          long: position.coords.longitude
        };
        return defer.resolve(loc);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return GPS;
  }
]);
