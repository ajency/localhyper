angular.module('LocalHyper.auth').factory('AuthAPI', [
  '$q', 'App', '$http', '$rootScope', 'User', function($q, App, $http, $rootScope, User) {
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
      var defer, name, phone;
      defer = $q.defer();
      phone = user.phone.toString();
      name = user.name;
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
      var defer, name, phone;
      defer = $q.defer();
      phone = user.phone.toString();
      name = user.name;
      this.isExistingUser().then(function(data) {
        if (!data.existing) {
          return this.signUpNewUser(phone, name);
        } else {
          return this.loginExistingUser(phone, name, data.userObj);
        }
      }).then(function(success) {
        return defer.resolve(success);
      }, (function(_this) {
        return function(error) {
          return _this.onParseJsError(defer, error);
        };
      })(this));
      return defer.promise;
    };
    AuthAPI.getUserDetails = function() {
      var addressGeoPoint, data, user;
      user = User.info('get');
      console.log(user);
      addressGeoPoint = new Parse.GeoPoint({
        latitude: user.geoCode.latitude,
        longitude: user.geoCode.longitude
      });
      return data = {
        addressGeoPoint: addressGeoPoint,
        address: user.address,
        city: user.address.city,
        area: user.address.city,
        deliveryRadius: user.deliveryRadius,
        businessName: user.businessName,
        displayName: user.name
      };
    };
    AuthAPI.loginExistingUser = function(phone, name, userObj) {
      var defer, newPassword, oldPassword, oldPasswordhash;
      defer = $q.defer();
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
              "displayName": name,
              "password": newPassword,
              "passwordHash": newPasswordHash,
              "installationId": installationId
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
    AuthAPI.signUpNewUser = function(phone, name) {
      var defer, password;
      defer = $q.defer();
      password = "" + phone + UUID;
      App.getInstallationId().then((function(_this) {
        return function(installationId) {
          var user;
          user = new Parse.User();
          user.set({
            "username": phone,
            "displayName": name,
            "password": password,
            "installationId": installationId,
            "userType": "seller",
            "passwordHash": _this.encryptPassword(password, phone)
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
