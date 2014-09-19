function UrlBuilder ($location, CiklApi, DateTime, Page) {

  var UrlBuilder = {};

  UrlBuilder.root = window.location.origin;
  UrlBuilder.path = null;

  UrlBuilder.getPath = function () {
    return UrlBuilder.path;
  };
  UrlBuilder.setPath = function (path) {
    UrlBuilder.path = path;
  };


  UrlBuilder.getLink = function (type, term) {
    var link = "";

    link = link + UrlBuilder.root + '/#/search?';

    link = link + '&type=' + encodeURIComponent(type);
    link = link + '&term=' + encodeURIComponent(term);
    link = link + '&page=' + encodeURIComponent(1);

    if (Page.getItemsPerPage()) {
      link = link + '&items=' + encodeURIComponent(Page.getItemsPerPage());
    }
    if (CiklApi.getOrder()) {
      link = link + '&order=' + encodeURIComponent(CiklApi.getOrder());
    }
    if (CiklApi.getOrderBy()) {
      link = link + '&by=' + encodeURIComponent(CiklApi.getOrderBy());
    }
    if (DateTime.getImportMinEpoch()) {
      link = link + '&importMin=' + encodeURIComponent(DateTime.getImportMinEpoch());
    }
    if (DateTime.getImportMaxEpoch()) {
      link = link + '&importMax=' + encodeURIComponent(DateTime.getImportMaxEpoch());
    }
    if (DateTime.getDetectMinEpoch()) {
      link = link + '&detectMin=' + encodeURIComponent(DateTime.getDetectMinEpoch());
    }
    if (DateTime.getDetectMaxEpoch()) {
      link = link + '&detectMax=' + encodeURIComponent(DateTime.getDetectMaxEpoch());
    }

    if( link.charAt( 0 ) === '&' ) {
      link = link.slice( 1 );
    }

    return link;
  };

  UrlBuilder.getPage = function (page) {
    var link = "";

    link = link + UrlBuilder.root + '/#/search?';

    if (CiklApi.getType()) {
      link = link + '&type=' + encodeURIComponent(CiklApi.getType());
    }
    if (CiklApi.getTerm()) {
      link = link + '&term=' + encodeURIComponent(CiklApi.getTerm());
    }

    link = link + '&page=' + encodeURIComponent(page);

    if (Page.getItemsPerPage()) {
      link = link + '&items=' + encodeURIComponent(Page.getItemsPerPage());
    }
    if (CiklApi.getOrder()) {
      link = link + '&order=' + encodeURIComponent(CiklApi.getOrder());
    }
    if (CiklApi.getOrderBy()) {
      link = link + '&by=' + encodeURIComponent(CiklApi.getOrderBy());
    }
    if (DateTime.getImportMinEpoch()) {
      link = link + '&importMin=' + encodeURIComponent(DateTime.getImportMinEpoch());
    }
    if (DateTime.getImportMaxEpoch()) {
      link = link + '&importMax=' + encodeURIComponent(DateTime.getImportMaxEpoch());
    }
    if (DateTime.getDetectMinEpoch()) {
      link = link + '&detectMin=' + encodeURIComponent(DateTime.getDetectMinEpoch());
    }
    if (DateTime.getDetectMaxEpoch()) {
      link = link + '&detectMax=' + encodeURIComponent(DateTime.getDetectMaxEpoch());
    }

    if( link.charAt( 0 ) === '&' ) {
      link = link.slice( 1 );
    }

    return link;
  };

  UrlBuilder.getItems = function (items) {
    var link = "";

    link = link + UrlBuilder.root + '/#/search?';

    if (CiklApi.getType()) {
      link = link + '&type=' + encodeURIComponent(CiklApi.getType());
    }
    if (CiklApi.getTerm()) {
      link = link + '&term=' + encodeURIComponent(CiklApi.getTerm());
    }
    if (Page.getCurrentPage()) {
      link = link + '&page=' + encodeURIComponent(Page.getCurrentPage());
    }

    link = link + '&items=' + encodeURIComponent(items);

    if (CiklApi.getOrder()) {
      link = link + '&order=' + encodeURIComponent(CiklApi.getOrder());
    }
    if (CiklApi.getOrderBy()) {
      link = link + '&by=' + encodeURIComponent(CiklApi.getOrderBy());
    }
    if (DateTime.getImportMinEpoch()) {
      link = link + '&importMin=' + encodeURIComponent(DateTime.getImportMinEpoch());
    }
    if (DateTime.getImportMaxEpoch()) {
      link = link + '&importMax=' + encodeURIComponent(DateTime.getImportMaxEpoch());
    }
    if (DateTime.getDetectMinEpoch()) {
      link = link + '&detectMin=' + encodeURIComponent(DateTime.getDetectMinEpoch());
    }
    if (DateTime.getDetectMaxEpoch()) {
      link = link + '&detectMax=' + encodeURIComponent(DateTime.getDetectMaxEpoch());
    }

    if( link.charAt( 0 ) === '&' ) {
      link = link.slice( 1 );
    }

    return link;
  };

  UrlBuilder.getSearchUrl = function () {
    var link = "";

    link = link + UrlBuilder.root + '/#/search?';

    if (CiklApi.getType()) {
      link = link + '&type=' + encodeURIComponent(CiklApi.getType());
    }
    if (CiklApi.getTerm()) {
      link = link + '&term=' + encodeURIComponent(CiklApi.getTerm());
    }
    if (Page.getCurrentPage()) {
      link = link + '&page=' + encodeURIComponent(Page.getCurrentPage());
    }
    if (Page.getItemsPerPage()) {
      link = link + '&items=' + encodeURIComponent(Page.getItemsPerPage());
    }
    if (CiklApi.getOrder()) {
      link = link + '&order=' + encodeURIComponent(CiklApi.getOrder());
    }
    if (CiklApi.getOrderBy()) {
      link = link + '&by=' + encodeURIComponent(CiklApi.getOrderBy());
    }
    if (DateTime.getImportMinEpoch()) {
      link = link + '&importMin=' + encodeURIComponent(DateTime.getImportMinEpoch());
    }
    if (DateTime.getImportMaxEpoch()) {
      link = link + '&importMax=' + encodeURIComponent(DateTime.getImportMaxEpoch());
    }
    if (DateTime.getDetectMinEpoch()) {
      link = link + '&detectMin=' + encodeURIComponent(DateTime.getDetectMinEpoch());
    }
    if (DateTime.getDetectMaxEpoch()) {
      link = link + '&detectMax=' + encodeURIComponent(DateTime.getDetectMaxEpoch());
    }

    if( link.charAt( 0 ) === '&' ) {
      link = link.slice( 1 );
    }

    return link;
  };

  UrlBuilder.update = function () {

    var url_params = {};

    if (CiklApi.getType()) {
      url_params['type'] = CiklApi.getType();
    }
    if (CiklApi.getTerm()) {
      url_params['term'] = CiklApi.getTerm();
    }
    if (Page.getCurrentPage()) {
      url_params['page'] = Page.getCurrentPage();
    }
    if (Page.getItemsPerPage()) {
      url_params['items'] = Page.getItemsPerPage();
    }
    if (CiklApi.getOrder()) {
      url_params['order'] = CiklApi.getOrder();
    }
    if (CiklApi.getOrderBy()) {
      url_params['by'] = CiklApi.getOrderBy();
    }
    if (DateTime.getImportMinEpoch()) {
      url_params['importMin'] = DateTime.getImportMinEpoch();
    }
    if (DateTime.getImportMaxEpoch()) {
      url_params['importMax'] = DateTime.getImportMaxEpoch();
    }
    if (DateTime.getDetectMinEpoch()) {
      url_params['detectMin'] = DateTime.getDetectMinEpoch();
    }
    if (DateTime.getDetectMaxEpoch()) {
      url_params['detectMax'] = DateTime.getDetectMaxEpoch();
    }

    $location.path('/search').search(url_params);
  };


  return UrlBuilder;
}
angular
    .module('app')
    .factory('UrlBuilder', UrlBuilder);
