angular.module('LocalHyper.auth').factory('AuthAPI', [
  '$q', 'App', '$http', function($q, App, $http) {
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
    AuthAPI.register = function(user) {
      var defer, name, phone;
      defer = $q.defer();
      phone = user.phone.toString();
      name = user.name;
      $http.get('users', {
        where: {
          "username": phone
        }
      }).then((function(_this) {
        return function(data) {
          var existingUser, userObj;
          userObj = data.data.results;
          existingUser = _.isEmpty(userObj) ? false : true;
          if (existingUser) {
            return _this.loginExistingUser(phone, name);
          } else {
            return _this.signUpNewUser(phone, name);
          }
        };
      })(this)).then(function(success) {
        return defer.resolve(success);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    AuthAPI.loginExistingUser = function(phone, name) {
      var defer, newPassword, newPasswordHash, oldPassword, oldPasswordhash;
      defer = $q.defer();
      oldPassword = oldPasswordhash = '';
      newPassword = newPasswordHash = '';
      $http.get('users', {
        where: {
          "username": phone
        }
      }).then((function(_this) {
        return function(data) {
          var userObj;
          userObj = data.data.results[0];
          oldPasswordhash = userObj.passwordHash;
          oldPassword = _this.decryptPassword(oldPasswordhash, phone);
          return Parse.User.logOut();
        };
      })(this)).then(function() {
        return Parse.User.logIn(phone, oldPassword);
      }).then((function(_this) {
        return function(user) {
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
          if (_.has(error, 'code')) {
            return _this.onParseJsError(defer, error);
          } else {
            return defer.reject(error);
          }
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
          return defer.reject('session_expired');
        default:
          return defer.reject('unknown_error');
      }
    };
    return AuthAPI;
  }
]);
