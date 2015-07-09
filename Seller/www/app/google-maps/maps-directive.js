angular.module('LocalHyper.googleMaps').directive('googleMap', [
  '$timeout', function($timeout) {
    return {
      restrict: 'E',
      replace: true,
      template: '<div data-tap-disabled="true" class="aj-maps">',
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
            center: new google.maps.LatLng(20.593684, 78.962880),
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
]).directive('googleMapSearch', [
  function() {
    return {
      restrict: 'A',
      replace: true,
      link: function(scope, el, attrs) {
        var initialize;
        initialize = function() {
          var autoComplete, input, options;
          input = document.getElementById('search');
          options = {
            componentRestrictions: {
              country: 'in'
            }
          };
          autoComplete = new google.maps.places.Autocomplete(el[0], options);
          return google.maps.event.addListener(autoComplete, 'places_changed', function() {
            return console.log('places_changed');
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
