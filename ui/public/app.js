(function () {
  angular.module('app', [
    'ngRoute',
    'ngAnimate',
    'ui.bootstrap'
  ]);

})();

function config ($routeProvider, $locationProvider) {
  $routeProvider
    .when('/',
    {
      templateUrl: 'views/search_intro.html',
      controller: 'IntroCtrl',
      controllerAs: 'intro'
    })
    .when('/:type/:term/:page/:numItems/:order/:orderBy/:importMin/:importMax/:detectMin/:detectMax',
    {
      templateUrl: 'views/search_timeline.html',
      controller: 'MainCtrl',
      controllerAs: 'm',
      resolve: MainCtrl.resolve
    })
    .when('/manual.html',
    {
      templateUrl: 'views/manual.html',
      controller: 'ManualCtrl',
      controllerAs: 'manual'
    })
    .otherwise(
    {
      redirectTo: '/'
    });

    // use the HTML5 History API
    $locationProvider.html5Mode(false);
}
angular
    .module('app')
    .config(config);


