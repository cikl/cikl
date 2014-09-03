function itemsPerPageSelector () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/itemsPerPageSelector.html'
  };
}
angular
    .module('app')
    .directive('itemsPerPageSelector', itemsPerPageSelector);