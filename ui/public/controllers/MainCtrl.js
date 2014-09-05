function MainCtrl ($timeout, $route, $routeParams, $location, CiklApi, DateTime, Page, UrlBuilder) {

  var m = this;

  m.route = $route;
  m.location = $location;
  m.routeParams = $routeParams;

  // Search form bindings and selector values
  m.artifact = {};
  m.artifact.type = CiklApi.getType();
  m.artifact.term = CiklApi.getTerm();
  m.types = ['fqdn','ipv4'];

  // Animation timeout delay
  $timeout(function () {
    m.query = CiklApi.getQuery();
  }, 300);

  // UrlBuilder functions
  m.getLink = function (type, term) {
    return UrlBuilder.getLink(type, term);
  };
  m.getPage = function (page) {
    return UrlBuilder.getPage(page);
  };
  m.getItems = function (items) {
    return UrlBuilder.getItems(items);
  };

  // Pagination functions
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
  m.getPages = function () {
    return Page.getPages();
  };
  m.checkCurrentPage = function (page) {
    return Page.checkCurrentPage(page);
  };
  m.isVisible = function (page) {
    return Page.isVisible(page);
  };
  m.getTotalItems = function () {
    return Page.getTotalItems();
  };
  m.getShowingStart = function () {
    return Page.getShowingStart();
  };
  m.getShowingEnd = function () {
    return Page.getShowingEnd();
  };
  m.isShowingSelected = function (num) {
    return Page.isShowingSelected(num);
  };
  m.setCurrentPage = function (page) {
    Page.updatePage(page);

    m.update();
  };

  // API settings getter functions
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

  // Sort true/false functions
  m.isAsc = function () {
    return CiklApi.isAsc();
  };
  m.isDesc = function () {
    return CiklApi.isDesc();
  };
  m.isImport = function () {
    return CiklApi.isImport();
  };
  m.isDetect = function () {
    return CiklApi.isDetect();
  };

  // Filter functions
  m.newDateFilter = function () {
    DateTime.newDateFilter();
  };
  m.checkDateFilter = function () {
    return DateTime.checkDateFilter();
  };
  m.clearDateFilter = function () {
    DateTime.clearDateFilter();
  };
  m.getDateNow = function () {
    return DateTime.getDateNow();
  };
  m.getDateMinusHour = function () {
    return DateTime.getDateMinusHour();
  };
  m.getDateMinusDay = function () {
    return DateTime.getDateMinusDay();
  };
  m.getDateMinusWeek = function () {
    return DateTime.getDateMinusWeek();
  };
  m.getDateMinusMonth = function () {
    return DateTime.getDateMinusMonth();
  };
  m.getDateMinusYear = function () {
    return DateTime.getDateMinusYear();
  };
  m.addDateFilter = function (filter) {
    DateTime.addDateFilter(filter);

    m.search();
  };
  m.setItemsPerPage = function (num) {
    Page.setItemsPerPage(num);

    m.search();
  };

  // Remove filter functions
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
    CiklApi.sortDetect();
    m.search();
  };
  m.sortImport = function() {
    CiklApi.sortImport();
    m.search();
  };
  m.sortSource = function() {
    CiklApi.sortSource();
    m.search();
  };
  m.sortProvider = function() {
    CiklApi.sortProvider();
    m.search();
  };
  m.sortFeed = function() {
    CiklApi.sortFeed();
    m.search();
  };
  m.sortTags = function() {
    CiklApi.sortTags();
    m.search();
  };

  // Cikl Api Query
  m.search = function() {
    $location.path(UrlBuilder.getSearch());
  };
  m.update = function() {
    $location.path(UrlBuilder.update());
  };

  // Search form
  m.formSearch = function(artifact) {
    CiklApi.setType(artifact.type);
    CiklApi.setTerm(artifact.term);

    m.search();
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