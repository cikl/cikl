// Import Min Time
function ImportMinTimeCtrl ($scope) {
  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
}
angular
    .module('app')
    .controller('ImportMinTimeCtrl', ImportMinTimeCtrl);

// Import Min Date
function ImportMinDateCtrl ($scope) {
  $scope.today = function() {
    m.import_min = new Date();
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
    .controller('ImportMinDateCtrl', ImportMinDateCtrl);

// Import Max Time
function ImportMaxTimeCtrl ($scope) {
  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
}
angular
    .module('app')
    .controller('ImportMaxTimeCtrl', ImportMaxTimeCtrl);

// Import Max Date
function ImportMaxDateCtrl ($scope) {
  $scope.today = function() {
    m.filter_import_max = new Date();
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
    .controller('ImportMaxDateCtrl', ImportMaxDateCtrl);