// Detect Min Time
function DetectMinTimeCtrl (DateTime) {
  var dmintime = this;

  dmintime.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    dmintime.opened = true;
  };

  dmintime.getDetectMin = function() {
    return DateTime.getDetectMin();
  };
}
angular
    .module('app')
    .controller('DetectMinTimeCtrl', DetectMinTimeCtrl);

// Detect Min Date
function DetectMinDateCtrl (DateTime) {
  var dmindate = this;

  dmindate.today = function() {
    DateTime.newDetectMin();
  };

  dmindate.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    dmindate.opened = true;
  };

  dmindate.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  dmindate.format = 'MMMM dd, yyyy';
}
angular
    .module('app')
    .controller('DetectMinDateCtrl', DetectMinDateCtrl);


// Detect Max Time
function DetectMaxTimeCtrl ($scope) {
  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
}
angular
    .module('app')
    .controller('DetectMaxTimeCtrl', DetectMaxTimeCtrl);

// Detect Max Date
  function DetectMaxDateCtrl ($scope) {
  $scope.today = function() {
    m.filter_detect_max = new Date();
  };

  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };

  $scope.dateOptions = {
    formatYear: 'yy',
    startingDay: 1
  };

  $scope.format = 'MMMM dd, yyyy';
}
angular
    .module('app')
    .controller('DetectMaxDateCtrl', DetectMaxDateCtrl);