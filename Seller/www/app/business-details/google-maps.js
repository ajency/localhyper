angular.module('LocalHyper.businessDetails').directive('ajGoogleMaps', [
  function() {
    return {
      restrict: 'E',
      replace: true,
      template: '<div data-tap-disabled="true"> <input id="search" type="text" size="40" placeholder="Search for location"> <div id="map-canvas" class="aj-maps"> </div> </div>',
      link: function(scope, ele, attr) {
        var gMap, hideAnchorTags, initSearchBox, mapOptions;
        hideAnchorTags = function(map) {
          return google.maps.event.addListenerOnce(map, 'idle', function() {
            return $('#map-canvas').find('a').each(function(index, el) {
              return $(el).parent().hide();
            });
          });
        };
        initSearchBox = function() {
          var autocomplete, input, options;
          input = document.getElementById('search');
          options = {
            componentRestrictions: {
              country: 'in'
            }
          };
          return autocomplete = new google.maps.places.Autocomplete(input, options);
        };
        mapOptions = {
          center: new google.maps.LatLng(20.593684, 78.962880),
          zoom: 5,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          zoomControl: false,
          mapTypeControl: false,
          streetViewControl: false
        };
        gMap = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
        hideAnchorTags(gMap);
        return initSearchBox();
      }
    };
  }
]);
