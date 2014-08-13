function IntroCtrl ($location, CiklApi, DateTime, Page) {

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

    // Set url
    // /:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax
    $location.path( '/'
            + CiklApi.getType() + '/'
            + CiklApi.getTerm() + '/'
            + Page.getCurrentPage() + '/'
            + Page.getItemsPerPage() + '/'
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