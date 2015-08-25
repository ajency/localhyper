angular.module('LocalHyper.products').controller('MakeRequestCtrl', [
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
        return this.latLng = null;
      },
      init: function() {
        if (_.isNull(this.latLng)) {
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
          return this.getCurrent();
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
        this.clearSellerMarkers();
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
                return _this.addUserLocationMarker(latLng);
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
      addSellerMarkers: function(sellers) {
        this.sellers.count = _.size(sellers);
        this.sellers.displayCount = true;
        this.sellers.found = true;
        return _.each(sellers, (function(_this) {
          return function(seller) {
            var geoPoint, loc;
            geoPoint = seller.sellerGeoPoint;
            loc = {
              lat: geoPoint.latitude,
              long: geoPoint.longitude
            };
            return _this.sellerMarkers.push(new google.maps.Marker({
              position: _this.toLatLng(loc),
              map: _this.map,
              icon: 'img/shop.png'
            }));
          };
        })(this));
      },
      clearSellerMarkers: function() {
        return _.each(this.sellerMarkers, function(marker) {
          return marker.setMap(null);
        });
      },
      findSellers: function() {
        var params, product;
        if (this.isLocationReady()) {
          this.sellers.displayCount = false;
          this.clearSellerMarkers();
          CSpinner.show('', 'Please wait as we find sellers for your location');
          product = ProductsAPI.productDetails('get');
          params = {
            "location": {
              latitude: this.latLng.lat(),
              longitude: this.latLng.lng()
            },
            "categoryId": product.category.id,
            "brandId": product.brand.id,
            "city": this.address.city,
            "area": this.address.city
          };
          return ProductsAPI.findSellers(params).then((function(_this) {
            return function(sellers) {
              _this.addSellerMarkers(sellers);
              return App.scrollTop();
            };
          })(this), function(error) {
            return CToast.show('Request failed, please try again');
          })["finally"](function() {
            App.resize();
            return CSpinner.hide();
          });
        }
      },
      addComments: function() {
        this.comments.temp = this.comments.text;
        return $ionicPopup.show({
          template: '<div class="list"> <label class="item item-input"> <textarea placeholder="Comments" ng-model="view.comments.temp"> </textarea> </label> </div>',
          title: 'Add comments',
          scope: $scope,
          buttons: [
            {
              text: 'Cancel'
            }, {
              text: '<b>Save</b>',
              type: 'button-positive',
              onTap: (function(_this) {
                return function(e) {
                  return _this.comments.text = _this.comments.temp;
                };
              })(this)
            }
          ]
        });
      },
      makeRequest: function() {
        var params, product;
        if (this.isLocationReady()) {
          if (!App.isOnline()) {
            return CToast.show(UIMsg.noInternet);
          } else {
            product = ProductsAPI.productDetails('get');
            CSpinner.show('', 'Please wait...');
            params = {
              "customerId": User.getId(),
              "productId": product.id,
              "categoryId": product.category.id,
              "brandId": product.brand.id,
              "comments": this.comments.text,
              "status": "open",
              "deliveryStatus": "",
              "location": {
                latitude: this.latLng.lat(),
                longitude: this.latLng.lng()
              },
              "address": this.address,
              "city": this.address.city,
              "area": this.address.city
            };
            return User.update({
              "address": params.address,
              "addressGeoPoint": new Parse.GeoPoint(params.location),
              "area": params.area,
              "city": params.city
            }).then(function() {
              return ProductsAPI.makeRequest(params);
            }).then((function(_this) {
              return function() {
                CToast.show('Your request has been made');
                $rootScope.$broadcast('make:request:success');
                return $timeout(function() {
                  return App.goBack(-1);
                }, 500);
              };
            })(this), function(error) {
              return CToast.show('Request failed, please try again');
            })["finally"](function() {
              return CSpinner.hide();
            });
          }
        }
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
    return $stateProvider.state('make-request', {
      url: '/make-request',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/products/make-request.html',
          controller: 'MakeRequestCtrl'
        }
      }
    });
  }
]);
