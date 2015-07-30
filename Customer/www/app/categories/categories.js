angular.module('LocalHyper.categories', []).controller('CategoriesCtrl', [
  '$scope', 'App', 'CategoriesAPI', 'Push', 'RequestAPI', '$rootScope', function($scope, App, CategoriesAPI, Push, RequestAPI, $rootScope) {
    $scope.view = {
      display: 'loader',
      errorType: '',
      parentCategories: [],
      init: function() {
        Push.register();
        this.getNotifications();
        return this.getCategories();
      },
      getNotifications: function() {
        return RequestAPI.getNotifications().then((function(_this) {
          return function(offerIds) {
            var notifications;
            notifications = _.size(offerIds);
            if (notifications > 0) {
              App.notification.badge = true;
              return App.notification.count = notifications;
            }
          };
        })(this));
      },
      getCategories: function() {
        return CategoriesAPI.getAll().then((function(_this) {
          return function(data) {
            console.log(data);
            return _this.onSuccess(data);
          };
        })(this), (function(_this) {
          return function(error) {
            return _this.onError(error);
          };
        })(this));
      },
      onSuccess: function(data) {
        this.display = 'noError';
        return this.parentCategories = data;
      },
      onError: function(type) {
        this.display = 'error';
        return this.errorType = type;
      },
      onTapToRetry: function() {
        this.display = 'loader';
        return this.getCategories();
      },
      onSubcategoryClick: function(children, categoryID) {
        CategoriesAPI.subCategories('set', children);
        return App.navigate('products', {
          categoryID: categoryID
        });
      }
    };
    $rootScope.$on('in:app:notification', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        return $scope.view.getNotifications();
      }
    });
    $rootScope.$on('push:notification:click', function(e, obj) {
      var payload;
      payload = obj.payload;
      if (payload.type === 'new_offer') {
        RequestAPI.requestDetails('set', {
          pushOfferId: payload.id
        });
        return App.navigate('request-details');
      }
    });
    return $scope.$on('$ionicView.afterEnter', function() {
      return App.hideSplashScreen();
    });
  }
]).config([
  '$stateProvider', function($stateProvider) {
    return $stateProvider.state('categories', {
      url: '/categories',
      parent: 'main',
      views: {
        "appContent": {
          templateUrl: 'views/categories/categories.html',
          controller: 'CategoriesCtrl'
        }
      }
    });
  }
]);
