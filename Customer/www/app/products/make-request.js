angular.module('LocalHyper.products').controller('MakeRequestCtrl', [
  '$scope', 'App', 'GPS', 'CToast', 'CDialog', '$timeout', 'GoogleMaps', 'UIMsg', 'CSpinner', 'User', 'ProductsAPI', '$ionicPopup', '$rootScope', '$q', function($scope, App, GPS, CToast, CDialog, $timeout, GoogleMaps, UIMsg, CSpinner, User, ProductsAPI, $ionicPopup, $rootScope, $q) {
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
      latitude: '',
      longitude: '',
      city: null,
      userInfo: '',
      user: {
        full: ''
      },
      addressObj: '',
      display: 'loader',
      errorType: '',
      locationSet: true,
      beforeInit: function() {
        this.user.full = '';
        this.latitude = '';
        this.longitude = '';
        return this.comments.text = '';
      },
      getDetails: function() {
        var userInfo;
        userInfo = User.getCurrent();
        this.userInfo = userInfo.attributes;
        if (_.isEmpty(this.userInfo.address)) {
          console.log('if user is not register');
          if (_.isNull(this.latLng)) {
            return $timeout((function(_this) {
              return function() {
                var loc;
                loc = {
                  lat: GEO_DEFAULT.lat,
                  long: GEO_DEFAULT.lng
                };
                return _this.getCurrent();
              };
            })(this), 200);
          } else {
            return this.getCurrent();
          }
        } else {
          this.locationSet = true;
          console.log('if user is register');
          this.display = 'noError';
          this.latitude = this.userInfo.addressGeoPoint._latitude;
          this.longitude = this.userInfo.addressGeoPoint._longitude;
          this.city = this.userInfo.address.city;
          this.user.full = this.userInfo.address.full;
          this.addressObj = this.userInfo.address;
          return this.loadSeller();
        }
      },
      init: function() {
        var cordinates, loc;
        if (App.previousState !== 'choose-location') {
          return this.getDetails();
        } else {
          console.log('choose-location');
          cordinates = GoogleMaps.setCordinates('get');
          this.latitude = cordinates.lat;
          this.longitude = cordinates.long;
          console.log(this.latitude);
          if (this.latitude !== '' && this.longitude !== '') {
            loc = {
              lat: this.latitude,
              long: this.longitude
            };
            this.locationSet = true;
            this.display = 'noError';
            this.latitude = cordinates.lat;
            this.longitude = cordinates.long;
            this.city = cordinates.addressObj.city;
            this.user.full = cordinates.addressObj.full;
            this.addressObj = cordinates.addressObj;
            return this.loadSeller();
          } else {
            return this.getDetails();
          }
        }
      },
      toLatLng: function(loc) {
        var latLng;
        latLng = new google.maps.LatLng(loc.lat, loc.long);
        return latLng;
      },
      onMapCreated: function(map) {
        return this.map = map;
      },
      getCurrent: function() {
        return GPS.isLocationEnabled().then((function(_this) {
          return function(enabled) {
            if (!enabled) {
              _this.locationSet = false;
              return _this.display = 'noError';
            } else {
              CToast.show('Getting current location');
              return GPS.getCurrentLocation().then(function(loc) {
                var latLng;
                console.log(loc);
                latLng = _this.toLatLng(loc);
                _this.latLng = latLng;
                _this.addressFetch = false;
                return GoogleMaps.getAddress(_this.latLng).then(function(address) {
                  _this.addressObj = address;
                  _this.address = address;
                  _this.address.full = GoogleMaps.fullAddress(address);
                  console.log(_this.address.full);
                  _this.addressFetch = true;
                  _this.latitude = _this.latLng.H;
                  _this.longitude = _this.latLng.L;
                  _this.city = _this.address.city;
                  _this.user.full = _this.address.full;
                  return _this.loadSeller();
                }, function(error) {
                  this.locationSet = false;
                  this.display = 'noError';
                  return console.log('Geocode error: ' + error);
                });
              }, function(error) {
                _this.locationSet = false;
                _this.display = 'noError';
                return CToast.show('Error locating your position');
              });
            }
          };
        })(this));
      },
      isLocationReady: function() {
        var ready;
        ready = this.latitude !== '' && this.longitude !== '' ? true : false;
        return ready;
      },
      loadSeller: function() {
        var params, product, sellers;
        sellers = [];
        console.log(this.userInfo);
        console.log(this.latitude);
        console.log(this.longitude);
        CSpinner.show('', 'Please wait as we find sellers for your location');
        product = ProductsAPI.productDetails('get');
        params = {
          "location": {
            latitude: this.latitude,
            longitude: this.longitude
          },
          "categoryId": product.category.id,
          "brandId": product.brand.id,
          "city": this.city,
          "area": this.city
        };
        return ProductsAPI.findSellers(params).then((function(_this) {
          return function(sellers) {
            console.log(sellers);
            _this.sellers.count = sellers.length;
            return _this.display = 'noError';
          };
        })(this), (function(_this) {
          return function(error) {
            CToast.show('Request failed, please try again');
            _this.display = 'error';
            return _this.errorType = error;
          };
        })(this))["finally"](function() {
          App.resize();
          return CSpinner.hide();
        });
      },
      addComments: function() {
        this.comments.temp = this.comments.text;
        return $ionicPopup.show({
          template: '<div class="list"> <label class="item item-input"> <textarea placeholder="Comments" ng-model="view.comments.temp" rows="5"> </textarea> </label> </div>',
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
        if (!this.isLocationReady()) {
          return CToast.show('Please select your location');
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
              latitude: this.latitude,
              longitude: this.longitude
            },
            "address": this.addressObj,
            "city": this.city,
            "area": this.city
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
      },
      onChangeLocation: function() {
        var loc;
        loc = {
          lat: this.latitude,
          long: this.longitude,
          addressObj: this.addressObj
        };
        GoogleMaps.setCordinates('set', loc);
        return App.navigate('choose-location');
      },
      onTapToRetry: function() {
        return this.init();
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
