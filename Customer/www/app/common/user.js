angular.module('LocalHyper.common').factory('User', [
  function() {
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
    User.info = function(action, data) {
      if (data == null) {
        data = {};
      }
      switch (action) {
        case 'set':
          return userInfo = {
            name: data.name,
            phone: data.phone
          };
        case 'get':
          return userInfo;
      }
    };
    return User;
  }
]);