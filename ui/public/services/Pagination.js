function Pagination () {

  var Pagination = {};

  Pagination.current_page = null;
  Pagination.total_items = null;
  Pagination.items_per_page = null;
  Pagination.max_size = 10;

  // Pagination Get functions
  Pagination.getCurrentPage = function () {
    return Pagination.current_page;
  };
  Pagination.getTotalItems = function () {
    return Pagination.total_items;
  };
  Pagination.getItemsPerPage = function () {
    return Pagination.items_per_page;
  };
  Pagination.getMaxSize = function () {
    return Pagination.max_size;
  };

  // Pagination Set functions
  Pagination.setCurrentPage = function (page_number) {
    Pagination.current_page = page_number;
  };
  Pagination.setTotalItems = function (total_items) {
    Pagination.total_items = total_items;
  };
  Pagination.setItemsPerPage = function (items_per_page) {
    Pagination.items_per_page = items_per_page;
  };
  Pagination.setMaxSize = function (max_size) {
    Pagination.max_size = max_size;
  };

  Pagination.pageChanged = function () {
    console.log('Page changed to: ' + Pagination.current_page)
  };

  return Pagination;
}
angular
    .module('app')
    .factory('Pagination', Pagination);