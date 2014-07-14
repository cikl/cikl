


var app = angular.module('ciklApp', [
  'ui.bootstrap',
  'sy.bootstrap.timepicker',
  'template/syTimepicker/timepicker.html',
  'template/syTimepicker/popup.html'
]);

app.controller("MainCtrl", function($scope, $http) {
  // Search Variables
  $scope.term = {};
  $scope.type = {};

  // ngShow boolean
  $scope.searched = false;

  // Sort initial type
  $scope.orderBy = 'import_time';
  $scope.order = 'desc';

  // Pagination settings variables
  $scope.itemsPerPage = 20;
  $scope.maxSize = 10;
  $scope.currentPage = 1;

  // Filter button collapse variables
  $scope.isCollapsedImport = true;
  $scope.isCollapsedDetect = true;

  // Date and Time Variables
  $scope.import_min = new Date();
  $scope.import_max = new Date();
  $scope.detect_min = new Date();
  $scope.detect_max = new Date();

  $scope.detect_min.setUTCDate($scope.detect_min.getUTCDate() -30);
  $scope.import_min.setUTCDate($scope.import_min.getUTCDate() -30);

  // Date and Time parent variables for child scopes
  var m = this;

  m.filter_import_min = new Date();
  m.filter_import_max = new Date();
  m.filter_detect_min = new Date();
  m.filter_detect_max = new Date();

  m.filter_detect_min.setUTCDate(m.filter_detect_min.getUTCDate() -30);
  m.filter_import_min.setUTCDate(m.filter_import_min.getUTCDate() -30);

  // Detect Min Time
  DetectMinTimeCtrl = function ($scope) {
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();

      $scope.opened = true;
    };
  };

  // Detect Min Date
  DetectMinDateCtrl = function ($scope) {
    $scope.today = function() {
      $scope.detect_min = new Date();
    };

    $scope.clear = function () {
      $scope.detect_min = null;
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
  };

  // Detect Max Time
  DetectMaxTimeCtrl = function ($scope) {
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();

      $scope.opened = true;
    };
  };

  // Detect Max Date
  DetectMaxDateCtrl = function ($scope) {
    $scope.today = function() {
      $scope.detect_max = new Date();
    };

    $scope.clear = function () {
      $scope.detect_max = null;
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
  };

  // Import Min Time
  ImportMinTimeCtrl = function ($scope) {
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();

      $scope.opened = true;
    };
  };

  // Import Min Date
  ImportMinDateCtrl = function ($scope) {
    $scope.today = function() {
      $scope.import_min = new Date();
    };

    $scope.clear = function () {
      $scope.import_min = null;
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
  };

  // Import Max Time
  ImportMaxTimeCtrl = function ($scope) {
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();

      $scope.opened = true;
    };
  };

  // Import Max Date
  ImportMaxDateCtrl = function ($scope) {
    $scope.today = function() {
      $scope.import_max = new Date();
    };

    $scope.clear = function () {
      $scope.import_max = null;
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
  };

  // Filter detect date/time
  $scope.filterDetect = function() {
    $scope.detect_min.setUTCDate(m.filter_detect_min.getUTCDate());
    $scope.detect_min.setUTCMonth(m.filter_detect_min.getUTCMonth());
    $scope.detect_min.setUTCFullYear(m.filter_detect_min.getUTCFullYear());

    $scope.detect_min.setUTCHours(m.filter_detect_min.getUTCHours());
    $scope.detect_min.setUTCMinutes(m.filter_detect_min.getUTCMinutes());
    $scope.detect_min.setUTCSeconds(m.filter_detect_min.getUTCSeconds());

    $scope.detect_max.setUTCDate(m.filter_detect_max.getUTCDate());
    $scope.detect_max.setUTCMonth(m.filter_detect_max.getUTCMonth());
    $scope.detect_max.setUTCFullYear(m.filter_detect_max.getUTCFullYear());

    $scope.detect_max.setUTCHours(m.filter_detect_max.getUTCHours());
    $scope.detect_max.setUTCMinutes(m.filter_detect_max.getUTCMinutes());
    $scope.detect_max.setUTCSeconds(m.filter_detect_max.getUTCSeconds());

    $scope.update();
  };

  // Filter import date/time
  $scope.filterImport = function() {
    $scope.import_min.setUTCDate(m.filter_import_min.getUTCDate());
    $scope.import_min.setUTCMonth(m.filter_import_min.getUTCMonth());
    $scope.import_min.setUTCFullYear(m.filter_import_min.getUTCFullYear());

    $scope.import_min.setUTCHours(m.filter_import_min.getUTCHours());
    $scope.import_min.setUTCMinutes(m.filter_import_min.getUTCMinutes());
    $scope.import_min.setUTCSeconds(m.filter_import_min.getUTCSeconds());

    $scope.import_max.setUTCDate(m.filter_import_max.getUTCDate());
    $scope.import_max.setUTCMonth(m.filter_import_max.getUTCMonth());
    $scope.import_max.setUTCFullYear(m.filter_import_max.getUTCFullYear());

    $scope.import_max.setUTCHours(m.filter_import_max.getUTCHours());
    $scope.import_max.setUTCMinutes(m.filter_import_max.getUTCMinutes());
    $scope.import_max.setUTCSeconds(m.filter_import_max.getUTCSeconds());

    $scope.update();
  };

  // Search form
  $scope.search = function(artifact) {
    $scope.term = artifact.term;
    $scope.type = artifact.type;
    $scope.searched = true;

    // Search Function
    $scope.update();
  };

  // Search artifacts update functions
  $scope.updateFqdn = function(fqdn) {
    $scope.type = 'fqdn';
    $scope.term = fqdn;
    document.getElementById("search-type").value = 'fqdn';
    document.getElementById("search-term").value = fqdn;
  }

  $scope.updateIpv4 = function(ipv4) {
    $scope.type = 'ipv4';
    $scope.term = ipv4;
    document.getElementById("search-type").value = 'ipv4';
    document.getElementById("search-term").value = ipv4;
  }

  $scope.$watch ('term', function () {
    $scope.update();
  });

  // Sort button functions
  $scope.sortDetect = function() {
    if ($scope.orderBy === 'detect_time') {
      if ($scope.order === 'desc') {
        $scope.order = 'asc';
      }
      else {
        $scope.order = 'desc';
      }
    }
    else {
      $scope.order = 'desc';
      $scope.orderBy = 'detect_time';
    }
  };

  $scope.sortImport = function() {
    if ($scope.orderBy === 'import_time') {
      if ($scope.order === 'desc') {
        $scope.order = 'asc';
      }
      else {
        $scope.order = 'desc';
      }
    }
    else {
      $scope.order = 'desc';
      $scope.orderBy = 'import_time';
    }
  };

  $scope.sortSource = function() {

  };

  // Pagination functions
  $scope.setPage = function (pageNo) {
    $scope.currentPage = pageNo;
  };

  $scope.pageChanged = function() {
    console.log('Page changed to: ' + $scope.currentPage);
  };

  $scope.$watch ('currentPage', function () {
    $scope.update();
  });

  // Sort watch functions
  $scope.$watch ('orderBy', function () {
    $scope.update();
  });

  $scope.$watch ('order', function () {
    $scope.update();
  });

  // API request function
  $scope.update = function () {
    var api_endpoint = window.location.origin + '/api/v1/query.json';

    var query_params = {
      start: 1 + ( ($scope.currentPage-1) * 10),
      per_page: $scope.itemsPerPage,
      order_by: $scope.orderBy,
      order: $scope.order,
      timing: 1,
      import_time_min: $scope.import_min,
      import_time_max: $scope.import_max,
      detect_time_min: $scope.detect_min,
      detect_time_max: $scope.detect_max
    };

    if ($scope.type === 'ipv4') {
      query_params["ipv4"] = $scope.term;
    }
    else if ($scope.type === 'fqdn') {
      query_params["fqdn"] = $scope.term;
    }

    $http.post(api_endpoint, query_params).success(function (data) {
      $scope.query = data;
      // Pagination total items
      $scope.totalItems = parseInt($scope.query.total_events);
    }).then(function() {

    });
  };



}); // End MainCtrl
