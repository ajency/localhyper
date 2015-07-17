angular.module('LocalHyper.auth').factory('AuthAPI', [
  '$q', 'App', '$http', '$rootScope', 'User', 'CategoriesAPI', function($q, App, $http, $rootScope, User, CategoriesAPI) {
    var AuthAPI, UUID;
    UUID = App.deviceUUID();
    AuthAPI = {};
    AuthAPI.getAESKey = function(phone) {
      var key;
      key = phone.split("").reverse().join("#*!$@");
      return key;
    };
    AuthAPI.encryptPassword = function(password, phone) {
      var encrypted, key;
      key = this.getAESKey(phone);
      encrypted = CryptoJS.AES.encrypt(password, key);
      return encrypted.toString();
    };
    AuthAPI.decryptPassword = function(passwordHash, phone) {
      var decrypted, key;
      key = this.getAESKey(phone);
      decrypted = CryptoJS.AES.decrypt(passwordHash, key);
      return decrypted.toString(CryptoJS.enc.Utf8);
    };
    AuthAPI.isExistingUser = function(user) {
      var defer, phone;
      defer = $q.defer();
      phone = user.phone.toString();
      user = new Parse.Query(Parse.User);
      user.equalTo("username", phone);
      user.find().then((function(_this) {
        return function(userObj) {
          var data;
          data = {};
          if (_.isEmpty(userObj)) {
            data.existing = false;
          } else {
            data.existing = true;
            data.userObj = userObj;
          }
          return defer.resolve(data);
        };
      })(this), (function(_this) {
        return function(error) {
          return _this.onParseJsError(defer, error);
        };
      })(this));
      return defer.promise;
    };
    AuthAPI.register = function(user) {
      var defer;
      defer = $q.defer();
      this.isExistingUser(user).then((function(_this) {
        return function(data) {
          if (!data.existing) {
            return _this.signUpNewUser();
          } else {
            return _this.loginExistingUser(data.userObj);
          }
        };
      })(this)).then(function(success) {
        return defer.resolve(success);
      }, (function(_this) {
        return function(error) {
          return _this.onParseJsError(defer, error);
        };
      })(this));
      return defer.promise;
    };
    AuthAPI.getUserDetails = function() {
      var addressGeoPoint, categoryChains, data, supportedBrands, supportedCategories, user;
      user = User.info('get');
      addressGeoPoint = new Parse.GeoPoint({
        latitude: user.geoCode.latitude,
        longitude: user.geoCode.longitude
      });
      categoryChains = CategoriesAPI.categoryChains('get');
      supportedCategories = [];
      supportedBrands = [];
      _.each(categoryChains, function(chains) {
        supportedCategories.push({
          "__type": "Pointer",
          "className": "Category",
          "objectId": chains.subCategory.id
        });
        return _.each(chains.brands, function(brand) {
          return supportedBrands.push({
            "__type": "Pointer",
            "className": "Brand",
            "objectId": brand.objectId
          });
        });
      });
      supportedBrands = _.map(_.groupBy(supportedBrands, function(brand) {
        return brand.objectId;
      }), function(grouped) {
        return grouped[0];
      });
      data = {
        phone: user.phone,
        businessName: user.businessName,
        addressGeoPoint: addressGeoPoint,
        address: user.address,
        city: user.address.city,
        area: user.address.city,
        deliveryRadius: parseInt(user.deliveryRadius),
        displayName: user.name,
        supportedCategories: supportedCategories,
        supportedBrands: supportedBrands
      };
      return data;
    };
    AuthAPI.loginExistingUser = function(userObj) {
      var defer, info, newPassword, oldPassword, oldPasswordhash, phone;
      defer = $q.defer();
      info = this.getUserDetails();
      phone = info.phone;
      newPassword = '';
      userObj = userObj[0];
      oldPasswordhash = userObj.get('passwordHash');
      oldPassword = this.decryptPassword(oldPasswordhash, phone);
      Parse.User.logOut().then(function() {
        return Parse.User.logIn(phone, oldPassword);
      }).then((function(_this) {
        return function(user) {
          var newPasswordHash;
          newPassword = "" + phone + UUID;
          newPasswordHash = _this.encryptPassword(newPassword, phone);
          return App.getInstallationId().then(function(installationId) {
            return user.save({
              "displayName": info.displayName,
              "password": newPassword,
              "passwordHash": newPasswordHash,
              "installationId": installationId,
              "businessName": info.businessName,
              "addressGeoPoint": info.addressGeoPoint,
              "address": info.address,
              "city": info.city,
              "area": info.city,
              "deliveryRadius": info.deliveryRadius,
              "supportedCategories": info.supportedCategories,
              "supportedBrands": info.supportedBrands
            });
          });
        };
      })(this)).then(function() {
        return Parse.User.logOut();
      }).then(function() {
        return Parse.User.logIn(phone, newPassword);
      }).then(function(success) {
        return defer.resolve(success);
      }, (function(_this) {
        return function(error) {
          return _this.onParseJsError(defer, error);
        };
      })(this));
      return defer.promise;
    };
    AuthAPI.signUpNewUser = function() {
      var defer, info, password, phone;
      defer = $q.defer();
      info = this.getUserDetails();
      phone = info.phone;
      password = "" + phone + UUID;
      App.getInstallationId().then((function(_this) {
        return function(installationId) {
          var user;
          user = new Parse.User();
          user.set({
            "userType": "seller",
            "username": phone,
            "displayName": info.displayName,
            "password": password,
            "passwordHash": _this.encryptPassword(password, phone),
            "installationId": installationId,
            "businessName": info.businessName,
            "addressGeoPoint": info.addressGeoPoint,
            "address": info.address,
            "city": info.city,
            "area": info.city,
            "deliveryRadius": info.deliveryRadius,
            "supportedCategories": info.supportedCategories,
            "supportedBrands": info.supportedBrands
          });
          return user.signUp();
        };
      })(this)).then(function(success) {
        return defer.resolve(success);
      }, (function(_this) {
        return function(error) {
          return _this.onParseJsError(defer, error);
        };
      })(this));
      return defer.promise;
    };
    AuthAPI.onParseJsError = function(defer, error) {
      switch (error.code) {
        case Parse.Error.CONNECTION_FAILED:
          return defer.reject('server_error');
        case Parse.Error.INVALID_SESSION_TOKEN:
          $rootScope.$broadcast('on:session:expiry');
          return defer.reject('session_expired');
        default:
          console.log('Error code: ' + error.code);
          return defer.reject('unknown_error');
      }
    };
    return AuthAPI;
  }
]);