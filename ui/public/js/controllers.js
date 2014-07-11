


var app = angular.module('ciklApp', [
  'ui.bootstrap',
  'sy.bootstrap.timepicker',
  'template/syTimepicker/timepicker.html',
  'template/syTimepicker/popup.html'
]);

app.controller("SearchCtrl", function($scope, $http) {
  $scope.term = {};

  // ngShow boolean
  $scope.searched = false;

  // Sort initial type
  $scope.orderBy = 'import_time';
  $scope.order = 'desc';

  // Pagination Settings
  $scope.itemsPerPage = 20;
  $scope.maxSize = 10;
  $scope.currentPage = 1;

  // Search page top form requests
  $scope.update = function(search) {
    $scope.term = search.term;
    $scope.type = search.type;


    if ($scope.type === 'ip-address') {
      $http.post('http://localhost:8080/api/v1/query/ipv4.json', {ipv4:$scope.term}).
          success(function (data) {
            $scope.query = data;
          }).
          then(function() {
            $scope.searched = true;

            // Pagination Settings
            $scope.totalItems = parseInt($scope.query.total_events);
          });
    }
    else if ($scope.type === 'dns') {
      $scope.current();
    }
  };

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

  // Pagination Settings
  $scope.setPage = function (pageNo) {
    $scope.currentPage = pageNo;
  };

  $scope.pageChanged = function() {
    console.log('Page changed to: ' + $scope.currentPage);
  };

  // Filter Button Collapse Initial state
  $scope.isCollapsedImport = true;
  $scope.isCollapsedDetect = true;

  $scope.$watch ('currentPage', function () {
    $scope.current();
  });

  $scope.$watch ('orderBy', function () {
    $scope.current();
  });

  $scope.$watch ('order', function () {
    $scope.current();
  });


  // API requests Function
  $scope.current = function () {
    $http.post('http://localhost:8080/api/v1/query/fqdn.json',
        {
          start: 1 + ( ($scope.currentPage-1) * 10),
          per_page: $scope.itemsPerPage,
          order_by: $scope.orderBy,
          order: $scope.order,
          timing: 1,
          fqdn: $scope.term
        }).
        success(function (data) {
          $scope.query = data;
        }).
        then(function() {
          $scope.searched = true;

          // Pagination Settings
          $scope.totalItems = parseInt($scope.query.total_events);
        }
    );
  };



}); // End searchCtrl


var DatepickerMinCtrl = function ($scope) {
  $scope.today = function() {
    $scope.date = new Date();
    $scope.date.setDate($scope.date.getDate() - 1);
  };
  $scope.today();

  $scope.clear = function () {
    $scope.date = null;
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

var TimepickerMinCtrl = function ($scope) {
  $scope.date = new Date();

  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
};


var DatepickerMaxCtrl = function ($scope) {
  $scope.today = function() {
    $scope.date = new Date();
  };
  $scope.today();

  $scope.clear = function () {
    $scope.date = null;
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

var TimepickerMaxCtrl = function ($scope) {
  $scope.date = new Date();

  $scope.open = function($event) {
    $event.preventDefault();
    $event.stopPropagation();

    $scope.opened = true;
  };
};