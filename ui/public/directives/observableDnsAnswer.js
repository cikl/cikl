function observablesDnsAnswer () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/observablesDnsAnswer.html'
  };
}
angular
    .module('app')
    .directive('observablesDnsAnswer', observablesDnsAnswer);

