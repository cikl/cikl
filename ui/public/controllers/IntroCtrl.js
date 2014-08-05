function IntroCtrl ($location, CiklApi, DateTime, Pagination) {

  var intro = this;

  // Search form
  intro.search = function(artifact) {
    // Initialize values of url params
    CiklApi.setType(artifact.type);
    CiklApi.setTerm(artifact.term);

    Pagination.setCurrentPage(1);
    Pagination.setItemsPerPage(20);

    CiklApi.setOrder('desc');
    CiklApi.setOrderBy('import_time');

    DateTime.newImportMin();
    DateTime.newImportMax();
    DateTime.initialImportMin();

    // Set url
    // /:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax
    $location.path( '/'
            + CiklApi.getType() + '/'
            + CiklApi.getTerm() + '/'
            + Pagination.getCurrentPage() + '/'
            + Pagination.getItemsPerPage() + '/'
            + CiklApi.getOrder() + '/'
            + CiklApi.getOrderBy() + '/'
            + DateTime.getImportMinEpoch() + '/'
            + DateTime.getImportMaxEpoch() + '/'
            + DateTime.getDetectMinEpoch() + '/'
            + DateTime.getDetectMaxEpoch()
    );
  };

}
angular
    .module('app')
    .controller('IntroCtrl', IntroCtrl);