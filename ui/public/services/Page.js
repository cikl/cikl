function Page () {

  var Page = {};

  Page.first_page = null;
  Page.prev_page = null;
  Page.current_page = null;
  Page.next_page = null;
  Page.last_page = null;
  Page.total_items = null;
  Page.items_per_page = null;
  Page.max_size = 10;

  // Page Get functions
  Page.getFirstPage = function () {
    return Page.first_page;
  };
  Page.getPrevPage = function () {
    return Page.prev_page;
  };
  Page.getCurrentPage = function () {
    return Page.current_page;
  };
  Page.getNextPage = function () {
    return Page.next_page;
  };
  Page.getLastPage = function () {
    return Page.last_page;
  };
  Page.getTotalItems = function () {
    return Page.total_items;
  };
  Page.getItemsPerPage = function () {
    return Page.items_per_page;
  };
  Page.getMaxSize = function () {
    return Page.max_size;
  };

  // Page Set functions
  Page.setCurrentPage = function (page_number) {
    Page.current_page = page_number;
  };
  Page.setTotalItems = function (total_items) {
    Page.total_items = total_items;
  };
  Page.setItemsPerPage = function (items_per_page) {
    Page.items_per_page = items_per_page;
  };
  Page.setMaxSize = function (max_size) {
    Page.max_size = max_size;
  };

  Page.updatePage = function (page) {

    // Set first page
    if (parseInt(page) == 1) {
      Page.first_page = null;
    }
    else {
      Page.first_page = 1;
    }

    // Set prev page
    if (parseInt(page) > 1) {
      Page.prev_page = parseInt(page) - 1;
    }
    else {
      Page.prev_page = null;
    }

    // Set current page
    Page.current_page = parseInt(page);

    // Set next page
    if (parseInt(page) < ( Math.floor( (Page.total_items - 1) / Page.items_per_page ) + 1)) {
      Page.next_page = parseInt(page) + 1;
    }
    else {
      Page.next_page = null;
    }

    // Set last page
    if (Page.total_items < 11) {
      Page.last_page = null;
    }
    else if (parseInt(page) < ( Math.floor( (Page.total_items - 1) / Page.items_per_page ) + 1) ) {
      Page.last_page = Math.floor( (Page.total_items - 1) / Page.items_per_page ) + 1;
    }
    else {
      Page.last_page = null;
    }

  };

  return Page;
}
angular
    .module('app')
    .factory('Page', Page);