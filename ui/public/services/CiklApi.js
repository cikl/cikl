function CiklApi ($q, $http, DateTime, Page) {

  var CiklApi = {};


  CiklApi.order_by = null;
  CiklApi.order = null;
  CiklApi.term = null;
  CiklApi.type = null;
  CiklApi.first = null;
  CiklApi.last = null;
  CiklApi.feeds = null;

  CiklApi.query = null;

  // Cikl API get function
  CiklApi.getOrderBy = function () {
    return CiklApi.order_by;
  };
  CiklApi.getOrder = function () {
    return CiklApi.order;
  };
  CiklApi.getTerm = function () {
    return CiklApi.term;
  };
  CiklApi.getType = function () {
    return CiklApi.type;
  };
  CiklApi.getFirst = function (){
    return CiklApi.first;
  };
  CiklApi.getLast = function (){
    return CiklApi.last;
  };
  CiklApi.getFeeds = function (){
    return CiklApi.feeds;
  };
  CiklApi.getQuery = function () {
    return CiklApi.query;
  };



  // Cikl API set function
  CiklApi.setOrderBy = function (order_by) {
    CiklApi.order_by = order_by;
  };
  CiklApi.setOrder = function (order) {
    CiklApi.order = order;
  };
  CiklApi.setTerm = function (term) {
    CiklApi.term = term;
  };
  CiklApi.setType = function (type) {
    CiklApi.type = type;
  };
  CiklApi.setFirst = function (first){
    CiklApi.first = first;
  };
  CiklApi.setLast = function (last){
    CiklApi.last = last;
  };
  CiklApi.setFeeds = function (feeds){
    CiklApi.feeds = feeds;
  };


  CiklApi.isAsc = function () {
    return (CiklApi.order == 'asc');
  };
  CiklApi.isDesc = function () {
    return (CiklApi.order == 'desc');
  };

  CiklApi.isImport = function () {
    return (CiklApi.order_by == 'import_time');
  };
  CiklApi.isDetect = function () {
    return (CiklApi.order_by == 'detect_time');
  };

  CiklApi.sortDetect = function() {
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
  };

  CiklApi.sortImport = function() {
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
  };


  // Cikl API request function
  CiklApi.queryApi = function () {

    var api_endpoint = window.location.origin + '/api/v1/query.json';


    var query_params = {
      start: 1 + ( (Page.getCurrentPage()-1) * Page.getItemsPerPage()),
      per_page: Page.getItemsPerPage(),
      order_by: CiklApi.order_by,
      order: CiklApi.order,
      timing: 1
    };

    if (CiklApi.type === 'ipv4') {
      query_params["ipv4"] = CiklApi.term;
    }
    else if (CiklApi.type === 'fqdn') {
      query_params["fqdn"] = CiklApi.term;
    }

    if (DateTime.getImportMin() !== null) {
      query_params["import_time_min"] = DateTime.getImportMin();
    }
    if (DateTime.getImportMax() !== null) {
      query_params["import_time_max"] = DateTime.getImportMax();
    }

    if (DateTime.getDetectMin() !== null) {
      query_params["detect_time_min"] = DateTime.getDetectMin();
    }
    if (DateTime.getDetectMax() !== null) {
      query_params["detect_time_max"] = DateTime.getDetectMax();
    }


    var deferred = $q.defer();

    try{
      $http.post(api_endpoint, query_params).success(function (data) {
        CiklApi.query = data;

        // Setter functions from results
        Page.setTotalItems(parseInt(CiklApi.query.total_events));
        Page.setShowingStart(CiklApi.query.query.start);
        Page.setShowingEnd(parseInt(CiklApi.query.query.start) + parseInt(CiklApi.query.query.per_page));
        CiklApi.setFirst(CiklApi.query.facets.min_import_time);
        CiklApi.setLast(CiklApi.query.facets.max_import_time);
        CiklApi.setFeeds(CiklApi.query.facets.feed_names.length);
        if ( Page.getCurrentPage() <= ( Math.floor( ( (Page.getTotalItems() -1) + Page.getItemsPerPage() ) / Page.getItemsPerPage() ))) {
          Page.updatePage(Page.getCurrentPage());
        }
        else {
          Page.updatePage(1);
          CiklApi.queryApi();
        }
        deferred.resolve(CiklApi.query);

      }).then(function() {

      });
    }catch(e){
      deferred.reject(e);
    }

    return deferred.promise;


  };

  return CiklApi;
}
angular
    .module('app')
    .factory('CiklApi', CiklApi);
