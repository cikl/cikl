function CiklApi ($q, $http, DateTime, Page) {

  var CiklApi = {};


  CiklApi.order_by = null;
  CiklApi.order = null;
  CiklApi.term = null;
  CiklApi.type = null;

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

    if (DateTime.getImportMinFilter() === true) {
      query_params["import_time_min"] = DateTime.getImportMin();
    }
    if (DateTime.getImportMaxFilter() === true) {
      query_params["import_time_max"] = DateTime.getImportMax();
    }

    if (DateTime.getDetectMinFilter() === true) {
      query_params["detect_time_min"] = DateTime.getDetectMin();
    }
    if (DateTime.getDetectMaxFilter() === true) {
      query_params["detect_time_max"] = DateTime.getDetectMax();
    }


    var deferred = $q.defer();

    try{
      $http.post(api_endpoint, query_params).success(function (data) {
        CiklApi.query = data;

        // Page total items
        Page.setTotalItems(parseInt(CiklApi.query.total_events));
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
