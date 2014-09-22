function observablesIpv4 () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/observablesIpv4.html'
  };
}
angular
    .module('app')
    .directive('observablesIpv4', observablesIpv4);