function RouteCtrl ($route, $routeParams, $location) {

  this.route = $route;
  this.location = $location;
  this.routeParams = $routeParams;



}
angular
    .module('app')
    .controller('RouteCtrl', RouteCtrl);