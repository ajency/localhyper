angular.module('LocalHyper.googleMaps', []).factory('GoogleMaps', [
  '$q', function($q) {
    var GoogleMaps, cordinates;
    GoogleMaps = {};
    cordinates = {};
    GoogleMaps.loadScript = function() {
      var defer, script;
      defer = $q.defer();
      if (_.isUndefined(window.google)) {
        script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = "https://maps.googleapis.com/maps/api/js?libraries=places&sensor=false" + ("&key=" + GOOGLE_MAPS_API_KEY + "&callback=onGMapScriptLoad");
        window.onGMapScriptLoad = function() {
          return defer.resolve();
        };
        script.onerror = function() {
          return defer.reject();
        };
        document.body.appendChild(script);
      } else {
        defer.resolve();
      }
      return defer.promise;
    };
    GoogleMaps.getAddress = function(latLng) {
      var defer, geocoder;
      defer = $q.defer();
      geocoder = new google.maps.Geocoder();
      geocoder.geocode({
        'latLng': latLng
      }, (function(_this) {
        return function(results, status) {
          var address;
          if (status === google.maps.GeocoderStatus.OK) {
            address = _this.formatAddress(results);
            return defer.resolve(address);
          } else {
            return defer.reject(status);
          }
        };
      })(this));
      return defer.promise;
    };
    GoogleMaps.formatAddress = function(results) {
      var address, data;
      address = {};
      data = results[0];
      address.full = data.formatted_address;
      _.each(data.address_components, function(addr) {
        switch (addr.types[0]) {
          case 'route':
            return address.address_line1 = addr.long_name;
          case 'sublocality_level_2':
            return address.address_line2 = addr.long_name;
          case 'sublocality_level_1':
            return address.address_line3 = addr.long_name;
          case 'locality':
            return address.city = addr.long_name;
          case 'administrative_area_level_2':
            return address.district = addr.long_name;
          case 'administrative_area_level_1':
            return address.state = addr.long_name;
          case 'country':
            return address.country = addr.long_name;
          case 'postal_code':
            return address.postal_code = addr.long_name;
        }
      });
      if (_.isUndefined(address.city)) {
        _.each(results, function(result) {
          return _.each(result.address_components, function(addr) {
            if (addr.types[0] === 'locality') {
              return address.city = addr.long_name;
            }
          });
        });
      }
      return address;
    };
    GoogleMaps.fullAddress = function(address) {
      var string;
      string = '';
      _.each(address, function(val, key) {
        if (key !== 'full') {
          return string += key === 'postal_code' ? "" + val : val + ", ";
        }
      });
      return string;
    };
    GoogleMaps.setCordinates = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return _.each(data, function(val, index) {
            return cordinates[index] = val;
          });
        case 'get':
          return cordinates;
      }
    };
    return GoogleMaps;
  }
]);
