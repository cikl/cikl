function observablesIpv6 () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/observablesIpv6.html'
  };
}
angular
    .module('app')
    .directive('observablesIpv6', observablesIpv6);