angular.module('LocalHyper.googleMaps').factory('GPS', [
  '$q', '$cordovaGeolocation', function($q, $cordovaGeolocation) {
    var GPS;
    GPS = {};
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
