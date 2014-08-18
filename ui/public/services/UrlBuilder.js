function UrlBuilder (CiklApi, DateTime, Page) {

  var UrlBuilder = {};


  UrlBuilder.url_root = window.location.origin;
  UrlBuilder.url = null;


  UrlBuilder.getLink = function (type, term) {
    var link = '';

    link = link + UrlBuilder.url_root + '/#/';
    link = link + type + '/';
    link = link + term + '/';
    link = link + '1/';
    link = link + Page.getItemsPerPage() + '/';
    link = link + CiklApi.getOrder() + '/';
    link = link + CiklApi.getOrderBy() + '/';
    link = link + DateTime.getImportMinEpoch() + '/';
    link = link + DateTime.getImportMaxEpoch() + '/';
    link = link + DateTime.getDetectMinEpoch() + '/';
    link = link + DateTime.getDetectMaxEpoch();

    return link;
  };

  UrlBuilder.getPage = function (page) {
    var link = '';

    link = link + UrlBuilder.url_root + '/#/';
    link = link + CiklApi.getType() + '/';
    link = link + CiklApi.getTerm() + '/';
    link = link + page + '/';
    link = link + Page.getItemsPerPage() + '/';
    link = link + CiklApi.getOrder() + '/';
    link = link + CiklApi.getOrderBy() + '/';
    link = link + DateTime.getImportMinEpoch() + '/';
    link = link + DateTime.getImportMaxEpoch() + '/';
    link = link + DateTime.getDetectMinEpoch() + '/';
    link = link + DateTime.getDetectMaxEpoch();

    return link;
  };

  UrlBuilder.getSearch = function () {
    var link = '';

    link = link + '/';
    link = link + CiklApi.getType() + '/';
    link = link + CiklApi.getTerm() + '/';
    link = link + '1/';
    link = link + Page.getItemsPerPage() + '/';
    link = link + CiklApi.getOrder() + '/';
    link = link + CiklApi.getOrderBy() + '/';
    link = link + DateTime.getImportMinEpoch() + '/';
    link = link + DateTime.getImportMaxEpoch() + '/';
    link = link + DateTime.getDetectMinEpoch() + '/';
    link = link + DateTime.getDetectMaxEpoch();

    return link;

  };


  return UrlBuilder;
}
angular
    .module('app')
    .factory('UrlBuilder', UrlBuilder);
