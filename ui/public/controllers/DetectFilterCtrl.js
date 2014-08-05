// Detect Min Time
function DetectMinTimeCtrl ($scope) {
  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
}
angular
    .module('app')
    .controller('DetectMinTimeCtrl', DetectMinTimeCtrl);

// Detect Min Date
function DetectMinDateCtrl ($scope) {
  $scope.today = function() {
    m.filter_detect_min = new Date();
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