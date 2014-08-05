function MainCtrl ($scope, $route, $routeParams, $location, CiklApi, DateTime, Pagination) {

  var m = this;

  m.route = $route;
  m.location = $location;
  m.routeParams = $routeParams;

  m.total_items = Pagination.total_items;
  m.current_page = Pagination.current_page;
  m.items_per_page = Pagination.items_per_page;
  m.max_size = Pagination.max_size;

  m.type = CiklApi.type;
  m.term = CiklApi.term;
  m.order = CiklApi.order;
  m.order_by = CiklApi.order_by;

  m.import_min = DateTime.import_min;
  m.import_max = DateTime.import_max;
  m.detect_min = DateTime.detect_min;
  m.detect_max = DateTime.detect_max;

  m.url_root = window.location.origin;

  m.query = CiklApi.getQuery();


  // Set Date & Time filters to start collapsed
  m.collapsedImport = false;
  m.collapsedDetect = false;


  m.getType = function () {
    return CiklApi.getType();
  };
  m.getTerm = function () {
    return CiklApi.getTerm();
  };


  m.getCurrentPage = function () {
    return Pagination.getCurrentPage();
  };
  m.getItemsPerPage = function () {
    return Pagination.getItemsPerPage();
  };


  m.getOrderBy = function () {
    return CiklApi.getOrderBy();
  };
  m.getOrder = function () {
    return CiklApi.getOrder();
  };


  m.getImportMin = function () {
    return DateTime.getImportMin();
  };
  m.getImportMax = function () {
    return DateTime.getImportMax();
  };
  m.getDetectMin = function () {
    return DateTime.getDetectMin();
  };
  m.getDetectMax = function () {
    return DateTime.getDetectMax();
  };

  m.removeImportMin = function() {
    DateTime.clearImportMin();

    m.search();
  };

  m.removeImportMax = function() {
    DateTime.clearImportMax();

    m.search();
  };

  m.removeDetectMin = function() {
    DateTime.clearDetectMin();

    m.search();
  };

  m.removeDetectMax = function() {
    DateTime.clearDetectMax();

    m.search();
  };

  // Sort button functions
  m.sortDetect = function() {
    if (CiklApi.getOrderBy() === 'detect_time') {
      if (CiklApi.getOrder() === 'desc') {
        CiklApi.setOrder('asc');
      }
      else {
        CiklApi.setOrder('desc');
      }
    }
    else {
      CiklApi.setOrder('desc');
      CiklApi.setOrderBy('detect_time');
    }

    m.search();
  };

  m.sortImport = function() {
    if (CiklApi.getOrderBy() === 'import_time') {
      if (CiklApi.getOrder() === 'desc') {
        CiklApi.setOrder('asc');
      }
      else {
        CiklApi.setOrder('desc');
      }
    }
    else {
      CiklApi.setOrder('desc');
      CiklApi.setOrderBy('import_time');
    }

    m.search();
  };

  m.sortSource = function() {

  };

  // Filter import date/time
  m.filterImport = function() {
    if (DateTime.getImportMinFilter()) {
      DateTime.setImportMinFilter(true);
    }
    else {
      DateTime.setImportMinFilter(false);
    }

    if (DateTime.getImportMaxFilter()) {
      DateTime.setImportMaxFilter(true);
    }
    else {
      DateTime.setImportMaxFilter(false);
    }

    m.search();
  };

  // Filter detect date/time
  m.filterDetect = function() {
    if (DateTime.getDetectMinFilter()) {
      DateTime.setDetectMinFilter(true);
    }
    else {
      DateTime.setDetectMinFilter(false);
    }

    if (DateTime.getDetectMaxFilter()) {
      DateTime.setDetectMaxFilter(true);
    }
    else {
      DateTime.setDetectMaxFilter(false);
    }

    m.search();
  };

  // Cikl Api Query
  m.search = function() {
    // /:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax
    $location.path( '/'
            + CiklApi.getType() + '/'
            + CiklApi.getTerm() + '/'
            + Pagination.getCurrentPage() + '/'
            + Pagination.getItemsPerPage() + '/'
            + CiklApi.getOrder() + '/'
            + CiklApi.getOrderBy() + '/'
            + DateTime.getImportMinEpoch() + '/'
            + DateTime.getImportMaxEpoch() + '/'
            + DateTime.getDetectMinEpoch() + '/'
            + DateTime.getDetectMaxEpoch()
    );
  };

  m.formSearch = function(artifact) {
    CiklApi.setType(artifact.type);
    CiklApi.setTerm(artifact.term);

    m.search();
  };

  m.updateFqdn = function(fqdn) {
    CiklApi.setType('fqdn');
    CiklApi.setTerm(fqdn);

    m.search();
  };

  m.updateIpv4 = function(ipv4) {
    CiklApi.setType('ipv4');
    CiklApi.setTerm(ipv4);

    m.search();
  };



  // Pagination
  m.getCurrentPage = function () {
    return Pagination.getCurrentPage();
  };
  m.getTotalItems = function () {
    return Pagination.getTotalItems();
  };
  m.getItemsPerPage = function () {
    return Pagination.getItemsPerPage();
  };
  m.setCurrentPage = function () {
    Pagination.setCurrentPage(m.current_page);
  };

  m.setPage = function (pageNo) {
    m.current_page = pageNo;
    Pagination.setCurrentPage(m.current_page);
  };

  m.pageChanged = function() {
    console.log('Page changed to: ' + m.current_page);
  };

//  $scope.$watch ('m.current_page', function () {
//    Pagination.setCurrentPage(m.current_page);
//    console.log('Current Page: ' + Pagination.getCurrentPage());
//    m.update();
//  });

  //  // Sort watch functions
  //  this.$watch ('orderBy', function () {
  //    this.update();
  //  });
  //
  //  this.$watch ('order', function () {
  //    this.update();
  //  });

}
// create the resolved property
MainCtrl.resolve = {
  // /:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax
  setType: function($route, CiklApi) {
    return CiklApi.setType($route.current.params.type);
  },
  setTerm: function($route, CiklApi) {
    return CiklApi.setTerm($route.current.params.term);
  },
  setCurrentPage: function($route, Pagination) {
    return Pagination.setCurrentPage($route.current.params.page);
  },
  setItemsPerPage: function($route, Pagination) {
    return Pagination.setItemsPerPage($route.current.params.numItems);
  },
  setOrder: function($route, CiklApi) {
    return CiklApi.setOrder($route.current.params.order);
  },
  setOrderBy: function($route, CiklApi) {
    return CiklApi.setOrderBy($route.current.params.orderBy);
  },

  setImportMinFromEpoch: function($route, DateTime) {
    return DateTime.setImportMinFromEpoch($route.current.params.importMin);
  },
  setImportMaxFromEpoch: function($route, DateTime) {
    return DateTime.setImportMaxFromEpoch($route.current.params.importMax);
  },
  setDetectMinFromEpoch: function($route, DateTime) {
    return DateTime.setDetectMinFromEpoch($route.current.params.detectMin);
  },
  setDetectMaxFromEpoch: function($route, DateTime) {
    return DateTime.setDetectMaxFromEpoch($route.current.params.detectMax);
  },

  queryApi: function (CiklApi) {
    return CiklApi.queryApi();
  }
};
angular
    .module('app')
    .controller('MainCtrl', MainCtrl)
    .config(config);