function MainCtrl ($route, $routeParams, $location, CiklApi, DateTime, Page, UrlBuilder) {

  var m = this;

  m.route = $route;
  m.location = $location;
  m.routeParams = $routeParams;

  m.total_items = Page.total_items;
  m.current_page = Page.current_page;
  m.items_per_page = Page.items_per_page;
  m.max_size = Page.max_size;

  m.type = CiklApi.type;
  m.term = CiklApi.term;
  m.order = CiklApi.order;
  m.order_by = CiklApi.order_by;

  m.import_min = DateTime.import_min;
  m.import_max = DateTime.import_max;
  m.detect_min = DateTime.detect_min;
  m.detect_max = DateTime.detect_max;

  m.query = CiklApi.getQuery();


  // Set Date & Time filters to start collapsed
  m.collapsedImport = false;
  m.collapsedDetect = false;


  m.getLink = function (type, term) {
    return UrlBuilder.getLink(type, term);
  };
  m.getPage = function (page) {
    return UrlBuilder.getPage(page);
  };

  m.getFirstPage = function () {
    return Page.getFirstPage();
  };
  m.getPrevPage = function () {
    return Page.getPrevPage();
  };
  m.getNextPage = function () {
    return Page.getNextPage();
  };
  m.getLastPage = function () {
    return Page.getLastPage();
  };


  m.getType = function () {
    return CiklApi.getType();
  };
  m.getTerm = function () {
    return CiklApi.getTerm();
  };

  m.getCurrentPage = function () {
    return Page.getCurrentPage();
  };
  m.getItemsPerPage = function () {
    return Page.getItemsPerPage();
  };

  m.getOrder = function () {
    return CiklApi.getOrder();
  };
  m.getOrderBy = function () {
    return CiklApi.getOrderBy();
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

  // Filter import date & time asc/desc
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

  // Filter detect date & time asc/desc
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
            + Page.getCurrentPage() + '/'
            + Page.getItemsPerPage() + '/'
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

  // Page
  m.getTotalItems = function () {
    return Page.getTotalItems();
  };
  m.setCurrentPage = function () {
    Page.setCurrentPage(m.current_page);
  };

}
// Resolve url params prior to page loading and update services variables
MainCtrl.resolve = {
  // Url params  /:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax
  setType: function($route, CiklApi) {
    return CiklApi.setType($route.current.params.type);
  },
  setTerm: function($route, CiklApi) {
    return CiklApi.setTerm($route.current.params.term);
  },
  setCurrentPage: function($route, Page) {
    return Page.setCurrentPage($route.current.params.page);
  },
  setItemsPerPage: function($route, Page) {
    return Page.setItemsPerPage($route.current.params.numItems);
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