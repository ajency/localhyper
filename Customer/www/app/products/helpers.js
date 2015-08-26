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
]).factory('PrimaryAttribute', [
  function() {
    var PrimaryAttribute;
    PrimaryAttribute = {};
    PrimaryAttribute.get = function(attrs) {
      var name, unit, value;
      if (_.isUndefined(attrs)) {
        return '';
      } else {
        attrs = attrs[0];
        if (_.contains(['N/A', 'NA'], attrs.value)) {
          '';
        } else {
          name = attrs.attribute.name;
        }
        value = s.humanize(attrs.value);
        unit = '';
        if (_.has(attrs.attribute, 'unit')) {
          unit = s.humanize(attrs.attribute.unit);
        }
        return "" + name + " : " + value + " " + unit;
      }
    };
    return PrimaryAttribute;
  }
]);
