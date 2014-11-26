module.exports = function(grunt) {
  grunt.initConfig({
    jasmine : {
      // Your project's source files
      src: [
        'app.js',
        'controllers/IntroCtrl.js',
        'controllers/MainCtrl.js',
        'directives/itemsPerPageSelector.js',
        'directives/observableDnsAnswer.js',
        'directives/observableFqdn.js',
        'directives/observableIpv4.js',
        'directives/observableIpv6.js',
        'directives/pageSelector.js',
        'services/CiklApi.js',
        'services/DateTime.js',
        'services/Page.js',
        'services/UrlBuilder.js'
      ],
      options: {
        // Your Jasmine spec files
        specs: [
          'spec/**/*Spec.js',
          'spec/*Spec.js'
        ],
        // Your spec runner location
        //host: 'http://localhost:63342/cikl/SpecRunner.html'
        vendor: [
          'js/jquery-2.1.1.js',
          'js/bootstrap.js',
          'js/moment.js',
          'js/ui_bootstrap-tpls-0.11.0.js',
          'js/angular.js',
          'js/angular-mocks.js',
          'js/angular-animate.js',
          'js/angular-resources.js',
          'js/angular-route.js'

        ]
      }
    }
  });

  // Register tasks.
  grunt.loadNpmTasks('grunt-contrib-jasmine');

  // Default task.
  grunt.registerTask('default', 'jasmine');
};
