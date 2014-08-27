function observablesFqdn () {
  return {
    restrict: 'EA',
    templateUrl: 'templates/observablesFqdn.html'
  };
}
angular
    .module('app')
    .directive('observablesFqdn', observablesFqdn);