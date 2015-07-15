angular.module('LocalHyper.common').factory('User', [
  '$q', function($q) {
    var User, userInfo;
    User = {};
    userInfo = {};
    User.isLoggedIn = function() {
      var loggedIn, user;
      user = Parse.User.current();
      loggedIn = _.isNull(user) ? false : true;
      return loggedIn;
    };
    User.getSessionToken = function() {
      var user;
      user = Parse.User.current();
      return user.getSessionToken();
    };
    User.getCurrent = function() {
      var user;
      user = Parse.User.current();
      return user;
    };
    User.getId = function() {
      return this.getCurrent().id;
    };
    User.update = function(params) {
      var defer;
      defer = $q.defer();
      this.getCurrent().save(params).then(function() {
        return defer.resolve();
      }, function(error) {
        return defer.reject(error);
      });
      return defer.promise;
    };
    User.info = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return _.each(data, function(val, index) {
            return userInfo[index] = val;
          });
        case 'get':
          return userInfo;
      }
    };
    return User;
  }
]);
