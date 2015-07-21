angular.module('LocalHyper.BusinessDetailStorage', []).factory('BusinessDetailStorage', [
  function() {
    var BusinessStorage;
    BusinessStorage = {
      setBussinessName: function(businessName) {
        return localforage.setItem('businessName', businessName);
      },
      setFullName: function(fullName) {
        return localforage.setItem('fullName', fullName);
      },
      setPhoneNo: function(phoneNo) {
        return localforage.setItem('phoneNo', phoneNo);
      },
      setRadius: function(radius) {
        return localforage.setItem('radius', radius);
      },
      setAddress: function(address) {
        return localforage.setItem('address', address);
      },
      getBussinessName: function() {
        var businessName;
        return businessName = localforage.getItem('businessName');
      },
      getFullName: function() {
        var fullName;
        return fullName = localforage.getItem('fullName');
      },
      getPhoneNo: function() {
        var phoneNo;
        return phoneNo = localforage.getItem('phoneNo');
      },
      getRadius: function() {
        var radius;
        return radius = localforage.getItem('radius');
      },
      getAddress: function() {
        var address;
        return address = localforage.getItem('address');
      }
    };
    return BusinessStorage;
  }
]);
