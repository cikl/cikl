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
  Page.start = null;
  Page.end = null;

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
  Page.getShowingStart = function () {
    return Page.start;
  };
  Page.getShowingEnd = function () {
    return Page.end;
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
  Page.setShowingStart = function (start) {
    Page.start = start;
  };
  Page.setShowingEnd = function (end) {
    Page.end = end;
  };

  // Return true if page is current page else false
  Page.checkCurrentPage = function (page) {
    return (parseInt(page) == Page.current_page);
  };

  // Create Pages array for pagination directive
  Page.getPages = function () {
    var pages = new Array;

    for (var i = 1; i <= ( Math.floor( ( (parseInt(Page.total_items) - 1) + parseInt(Page.items_per_page) ) / parseInt(Page.items_per_page) )); i++) {
      pages.push(i);
    }
    return pages;
  };

  // Shows pagination links for 5 pages before and 5 pages after Page.current_page
  Page.isVisible = function (page) {
    if (parseInt(Page.current_page) <= 5) {
      if (page <= 11) {
        return true;
      }
      else {
        return false;
      }
    }
    else if (parseInt(Page.current_page) >= ((Math.floor( (Page.total_items - 1) / Page.items_per_page ) + 1) -5)) {
      if (page >= ((Math.floor( (Page.total_items - 1) / Page.items_per_page ) + 1) -10)){
        return true;
      }
      else {
        return false;
      }
    }
    else if ((parseInt(Page.current_page) - 5) <= page && page <= (parseInt(Page.current_page) + 5)) {
      return true;
    }
    else {
      return false;
    }
  };

  // Update Page variables after API call
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