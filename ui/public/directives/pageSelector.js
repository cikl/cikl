function pageSelector () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/pageSelector.html'
  };
}
angular
    .module('app')
    .directive('pageSelector', pageSelector);




