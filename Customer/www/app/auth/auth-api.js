angular.module('LocalHyper.auth').factory('AuthAPI', [
  '$q', 'App', function($q, App) {
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
    AuthAPI.isExistingUser = function(phone) {
      var defer, userQuery;
      defer = $q.defer();
      userQuery = new Parse.Query(Parse.User);
      userQuery.equalTo("username", phone);
      userQuery.find().then(function(userObj) {
        var existing;
        existing = _.isEmpty(userObj) ? false : true;
        return defer.resolve(existing);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    AuthAPI.register = function(user) {
      var defer, name, onError, onSuccess, phone;
      defer = $q.defer();
      phone = user.phone.toString();
      name = user.name;
      onSuccess = function(success) {
        return defer.resolve(success);
      };
      onError = function(error) {
        return defer.reject(error);
      };
      this.isExistingUser(phone).then((function(_this) {
        return function(exists) {
          if (exists) {
            return _this.loginExistingUser(phone, name).then(onSuccess, onError);
          } else {
            return _this.signUpNewUser(phone, name).then(onSuccess, onError);
          }
        };
      })(this), onError);
      return defer.promise;
    };
    AuthAPI.loginExistingUser = function(phone, name) {
      var defer, onError, updateUser, userQuery;
      defer = $q.defer();
      onError = function(error) {
        return defer.reject(error);
      };
      updateUser = (function(_this) {
        return function(user) {
          var password, passwordHash;
          password = "" + phone + UUID;
          passwordHash = _this.encryptPassword(password, phone);
          user.set("displayName", name);
          user.set("password", password);
          user.set("passwordHash", passwordHash);
          return user.save().then(function(success) {
            return defer.resolve(success);
          }, onError);
        };
      })(this);
      userQuery = new Parse.Query(Parse.User);
      userQuery.equalTo("username", phone);
      userQuery.find().then((function(_this) {
        return function(userObj) {
          var password, passwordHash;
          passwordHash = userObj[0].get('passwordHash');
          password = _this.decryptPassword(passwordHash, phone);
          return Parse.User.logOut().then(function() {
            return Parse.User.logIn(phone, password).then(updateUser, onError);
          }, onError);
        };
      })(this), onError);
      return defer.promise;
    };
    AuthAPI.signUpNewUser = function(phone, name) {
      var defer, password, passwordHash, user;
      defer = $q.defer();
      password = "" + phone + UUID;
      user = new Parse.User();
      user.set("username", phone);
      user.set("displayName", name);
      user.set("password", password);
      passwordHash = this.encryptPassword(password, phone);
      user.set("passwordHash", passwordHash);
      user.signUp().then(function(success) {
        return defer.resolve(success);
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    return AuthAPI;
  }
]);
