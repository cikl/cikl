function IntroCtrl (UrlBuilder, CiklApi, DateTime, Page) {

  var intro = this;

  // Search form
  intro.search = function(artifact) {
    // Initialize values of url params
    CiklApi.setType(artifact.type);
    CiklApi.setTerm(artifact.term);

    Page.setCurrentPage(1);
    Page.setItemsPerPage(20);

    CiklApi.setOrder('desc');
    CiklApi.setOrderBy('import_time');

    DateTime.newImportMin();
    DateTime.newImportMax();
    DateTime.initialImportMin();

    // Set url and redirect to /search view
    UrlBuilder.update();
  };

}
angular
    .module('app')
    .controller('IntroCtrl', IntroCtrl);