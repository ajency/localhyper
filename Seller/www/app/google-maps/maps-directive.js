angular.module('LocalHyper.googleMaps').directive('googleMap', [
  '$timeout', function($timeout) {
    return {
      restrict: 'E',
      replace: true,
      template: '<div data-tap-disabled="true">',
      scope: {
        onCreate: '&'
      },
      link: function(scope, el, attr) {
        var hideAnchorTags, initialize;
        hideAnchorTags = function() {
          return $timeout(function() {
            return $(el).find('a').parent().hide();
          });
        };
        initialize = function() {
          var map, mapOptions;
          mapOptions = {
            center: new google.maps.LatLng(GEO_DEFAULT.lat, GEO_DEFAULT.lng),
            zoom: 5,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            zoomControl: false,
            mapTypeControl: false,
            streetViewControl: false
          };
          map = new google.maps.Map(el[0], mapOptions);
          google.maps.event.addListenerOnce(map, 'idle', function() {
            return hideAnchorTags(map);
          });
          return scope.onCreate({
            map: map
          });
        };
        if (document.readyState === "complete") {
          return initialize();
        } else {
          return google.maps.event.addDomListener(window, 'load', initialize);
        }
      }
    };
  }
]);
