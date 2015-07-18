angular.module('LocalHyper.products').directive('ajLoadingBackDrop', [
  '$timeout', '$ionicLoading', function($timeout, $ionicLoading) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          return $('.loading-container').on('click', function(event) {
            var isBackdrop;
            isBackdrop = $(event.target).hasClass('loading-container');
            if (isBackdrop) {
              return $ionicLoading.hide();
            }
          });
        });
      }
    };
  }
]).directive('ajCountDown', [
  '$timeout', '$parse', function($timeout, $parse) {
    return {
      restrict: 'A',
      link: function(scope, el, attrs) {
        return $timeout(function() {
          var createdAt, m, total, totalStr;
          createdAt = $parse(attrs.createdAt)(scope);
          m = moment(createdAt);
          total = moment(m).add(24, 'hours');
          totalStr = moment(total).format('YYYY/MM/DD HH:mm:ss');
          return $(el).countdown(totalStr, function(event) {
            return $(el).html(event.strftime('%-H:%-M:%-S'));
          });
        });
      }
    };
  }
]);
