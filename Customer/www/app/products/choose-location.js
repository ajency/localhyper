angular.module('LocalHyper.products').controller('ChooseLocationCtrl', [
  '$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout', 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope', function($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner, User, ProductsAPI, $ionicPopup, $rootScope) {
    $scope.view = {
      latLng: null,
      addressFetch: true,
      sellerMarkers: [],
      sellers: {
        count: 0,
        displayCount: false,
        found: false
      },
      comments: {
        text: ''
      },
      beforeInit: function() {
        this.reset();
        this.searchText = '';
        this.comments.text = '';
        this.address = null;
        this.latLng = null;
        return this.map.setZoom(5);
      },
      setMapCenter: function(loc) {
        var latLng;
        latLng = new google.maps.LatLng(loc.lat, loc.long);
        this.map.setCenter(latLng);
        return latLng;
      },
      init: function() {
        var cordinates, latLng, loc;
        cordinates = GoogleMaps.setCordinates('get');
        console.log('---38--');
        console.log(cordinates);
        this.latitude = cordinates.lat;
        this.longitude = cordinates.long;
        if (this.latitude === '') {
          return $timeout((function(_this) {
            return function() {
              var loc;
              loc = {
                lat: GEO_DEFAULT.lat,
                long: GEO_DEFAULT.lng
              };
              _this.map.setCenter(_this.toLatLng(loc));
              return _this.getCurrent();
            };
          })(this), 200);
        } else {
          loc = {
            lat: this.latitude,
            long: this.longitude
          };
          latLng = this.setMapCenter(loc);
          this.map.setZoom(15);
          return this.addPlaceMarker(latLng);
        }
      },
      reset: function(clearPlace) {
        if (clearPlace == null) {
          clearPlace = true;
        }
        App.resize();
        if (this.userMarker) {
          this.userMarker.setMap(null);
        }
        if (this.placeMarker && clearPlace) {
          this.placeMarker.setMap(null);
        }
        this.sellers.found = false;
        return this.sellers.displayCount = false;
      },
      toLatLng: function(loc) {
        var latLng;
        latLng = new google.maps.LatLng(loc.lat, loc.long);
        return latLng;
      },
      onMapCreated: function(map) {
        this.map = map;
        return google.maps.event.addListener(this.map, 'click', (function(_this) {
          return function(event) {
            return $scope.$apply(function() {
              _this.searchText = '';
              return _this.addPlaceMarker(event.latLng);
            });
          };
        })(this));
      },
      onPlaceChange: function(latLng) {
        console.log('--69--');
        console.log(latLng);
        this.latLng = latLng;
        this.map.setCenter(latLng);
        this.map.setZoom(15);
        return this.addPlaceMarker(latLng);
      },
      getCurrent: function() {
        return GPS.isLocationEnabled().then((function(_this) {
          return function(enabled) {
            if (!enabled) {
              return _this.showAlert();
            } else {
              CToast.show('Getting current location');
              return GPS.getCurrentLocation().then(function(loc) {
                var latLng;
                latLng = _this.toLatLng(loc);
                _this.searchText = '';
                _this.map.setCenter(latLng);
                _this.map.setZoom(15);
                return _this.addPlaceMarker(latLng);
              }, function(error) {
                return CToast.show('Error locating your position');
              });
            }
          };
        })(this));
      },
      addUserLocationMarker: function(latLng) {
        this.latLng = latLng;
        this.reset();
        this.setAddress();
        this.userMarker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          icon: 'img/current-location.png'
        });
        return this.userMarker.setMap(this.map);
      },
      addPlaceMarker: function(latLng) {
        this.latLng = latLng;
        this.reset();
        this.setAddress();
        this.placeMarker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          draggable: true
        });
        this.placeMarker.setMap(this.map);
        return google.maps.event.addListener(this.placeMarker, 'dragend', (function(_this) {
          return function(event) {
            return $scope.$apply(function() {
              _this.latLng = event.latLng;
              _this.reset(false);
              _this.searchText = '';
              return _this.setAddress();
            });
          };
        })(this));
      },
      showAlert: function() {
        var positiveBtn;
        positiveBtn = App.isAndroid() ? 'Open Settings' : 'Ok';
        return CDialog.confirm('Use location?', 'Please enable location settings', [positiveBtn, 'Cancel']).then(function(btnIndex) {
          if (btnIndex === 1) {
            return GPS.switchToLocationSettings();
          }
        });
      },
      setAddress: function() {
        this.addressFetch = false;
        return GoogleMaps.getAddress(this.latLng).then((function(_this) {
          return function(address) {
            _this.address = address;
            _this.address.full = GoogleMaps.fullAddress(address);
            return _this.addressFetch = true;
          };
        })(this), function(error) {
          return console.log('Geocode error: ' + error);
        });
      },
      isLocationReady: function() {
        var ready;
        ready = !_.isNull(this.latLng) && this.addressFetch ? true : false;
        if (!ready) {
          GPS.isLocationEnabled().then((function(_this) {
            return function(enabled) {
              if (enabled) {
                return CToast.show('Please wait, getting location details...');
              } else {
                return CToast.show('Please search for location');
              }
            };
          })(this));
        }
        return ready;
      },
      confirmLocation: function() {
        var loc, user;
        console.log('add full');
        console.log(this.address);
        console.log(this.address.city);
        console.log(this.address.full);
        loc = {
          lat: this.latLng.lat(),
          long: this.latLng.lng(),
          addressObj: this.address
        };
        GoogleMaps.setCordinates('set', loc);
        user = GoogleMaps.setCordinates('get');
        console.log(user);
        return App.navigate('make-request');
      }
    };
    $scope.$on('$ionicView.beforeEnter', function() {
      $scope.view.beforeInit();
      return App.scrollTop();
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return $scope.view.init();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('choose-location', {
      url: '/choose-location',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/choose-location.html',
          controller: 'ChooseLocationCtrl'
        }
      }
    });
  }
]);
