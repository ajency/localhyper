angular.module('LocalHyper.products').directive('ajLoadingBackDrop', [
  '$timeout', '$ionicLoading', function($timeout, $ionicLoading) {
    return {
      restrict: 'A',
      scope: {
        onHidden: '&'
      },
      link: function(scope, el, attrs) {
        var onContainerClick;
        onContainerClick = function(event) {
          var target;
          target = $(event.target);
          if (target.hasClass('loading-container')) {
            $('.loading-container').off('click', onContainerClick);
            return scope.$apply(function() {
              return scope.onHidden();
            });
          } else if (target.hasClass('button-assertive')) {
            return $('.loading-container').off('click', onContainerClick);
          }
        };
        return $timeout(function() {
          return $('.loading-container').on('click', onContainerClick);
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
