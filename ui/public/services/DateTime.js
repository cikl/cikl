function DateTime () {

  var DateTime = {};

  DateTime.import_min = null;
  DateTime.import_max = null;
  DateTime.detect_min = null;
  DateTime.detect_max = null;

  DateTime.import_min_filter = null;
  DateTime.import_max_filter = null;
  DateTime.detect_min_filter = null;
  DateTime.detect_max_filter = null;

  // Date & Time filter collapse variables
  DateTime.collapsed_import = null;
  DateTime.collapsed_detect = null;


  // Date and Time get function
  DateTime.getImportMin = function () {
    return DateTime.import_min;
  };
  DateTime.getImportMax = function () {
    return DateTime.import_max;
  };
  DateTime.getDetectMin = function () {
    return DateTime.detect_min;
  };
  DateTime.getDetectMax = function () {
    return DateTime.detect_max;
  };

  DateTime.getImportMinFilter = function () {
    return DateTime.import_min_filter;
  };
  DateTime.getImportMaxFilter = function () {
    return DateTime.import_min_filter;
  };
  DateTime.getDetectMinFilter = function () {
    return DateTime.detect_min_filter;
  };
  DateTime.getDetectMaxFilter = function () {
    return DateTime.detect_max_filter;
  };

  DateTime.getCollapsedImport = function() {
    return DateTime.collapsed_import;
  };
  DateTime.getCollapsedDetect = function() {
    return DateTime.collapsed_detect;
  };


  // Date and Time set function
  DateTime.setImportMin = function (import_min) {
    DateTime.import_min = import_min;
  };
  DateTime.setImportMax = function (import_max) {
    DateTime.import_max = import_max;
  };
  DateTime.setDetectMin = function (detect_min) {
    DateTime.detect_min = detect_min;
  };
  DateTime.setDetectMax = function (detect_max) {
    DateTime.detect_max = detect_max;
  };

  // Filter true/false set functions
  DateTime.setImportMinFilter = function (import_min_filter) {
    DateTime.import_min_filter = import_min_filter;
  };
  DateTime.setImportMaxFilter = function (import_max_filter) {
    DateTime.import_max_filter = import_max_filter;
  };
  DateTime.setDetectMinFilter = function (detect_min_filter) {
    DateTime.detect_min_filter = detect_min_filter;
  };
  DateTime.setDetectMaxFilter = function (detect_max_filter) {
    DateTime.detect_max_filter = detect_max_filter;
  };

  // Get epoch times for URL encoding
  DateTime.getImportMinEpoch = function() {
    if (DateTime.import_min === null) {
      return 'none';
    }
    else {
      return DateTime.import_min.getTime();
    }
  };
  DateTime.getImportMaxEpoch = function() {
    if (DateTime.import_max === null) {
      return 'none';
    }
    else {
      return DateTime.import_max.getTime();
    }
  };
  DateTime.getDetectMinEpoch = function() {
    if (DateTime.detect_min === null) {
      return 'none';
    }
    else {
      return DateTime.detect_min.getTime();
    }
  };
  DateTime.getDetectMaxEpoch = function() {
    if (DateTime.detect_max === null) {
      return 'none';
    }
    else {
      return DateTime.detect_max.getTime();
    }
  };

  // Parse URL epoch times back to dates
  DateTime.setImportMinFromEpoch = function(date) {
    if (date === 'none') {
      DateTime.import_min = null;
    }
    else {
      var d = new Date(parseInt(date));
      DateTime.import_min = d;
    }
  };
  DateTime.setImportMaxFromEpoch = function(date) {
    if (date === 'none') {
      DateTime.import_max = null;
    }
    else {
      var d = new Date(parseInt(date));
      DateTime.import_max = d;
    }
  };
  DateTime.setDetectMinFromEpoch = function(date) {
    if (date === 'none') {
      DateTime.detect_min = null;
    }
    else {
      var d = new Date(parseInt(date));
      DateTime.detect_min = d;
    }
  };
  DateTime.setDetectMaxFromEpoch = function(date) {
    if (date === 'none') {
      DateTime.detect_max = null;
    }
    else {
      var d = new Date(parseInt(date));
      DateTime.detect_max = d;
    }
  };

  // Clear Date and Time filters
  DateTime.clearImportMin = function () {
    DateTime.import_min = null;
  };
  DateTime.clearImportMax = function () {
    DateTime.import_max = null;
  };
  DateTime.clearDetectMin = function () {
    DateTime.detect_min = null;
  };
  DateTime.clearDetectMax = function () {
    DateTime.detect_max = null;
  };

  // Set Date and Time filters to new Date()
  DateTime.newImportMin = function () {
    DateTime.import_min = new Date();
  };
  DateTime.newImportMax = function () {
    DateTime.import_max = new Date();
  };
  DateTime.newDetectMin = function () {
    DateTime.detect_min = new Date();
  };
  DateTime.newDetectMax = function () {
    DateTime.detect_max = new Date();
  };

  // Initialize filter min dates to end of previous month
  DateTime.initialImportMin = function () {
    DateTime.import_min.setUTCDate(0);
  };
  DateTime.initialDetectMin = function () {
    DateTime.detect_min.setUTCDate(0);
  };

  // Create new date
  DateTime.newImportMin = function () {
    DateTime.import_min = new Date();
  };
  DateTime.newImportMax = function () {
    DateTime.import_max = new Date();
  };
  DateTime.newDetectMin = function () {
    DateTime.detect_min = new Date();
  };
  DateTime.newDetectMax = function () {
    DateTime.detect_max = new Date();
  };



  DateTime.checkImport = function() {
    if ( (DateTime.getImportMin() === null) && (DateTime.collapsed_import === false) ) {
      DateTime.newImportMin();
      DateTime.initialImportMin();
    }

    if ( (DateTime.getImportMax() === null) && (DateTime.collapsed_import === false) ) {
      DateTime.newImportMax();
    }
  };

  DateTime.checkDetect = function() {
    if ( (DateTime.getDetectMin() === null) && (DateTime.collapsed_detect === false) ) {
      DateTime.newDetectMin();
      DateTime.initialDetectMin();
    }

    if ( (DateTime.getDetectMax() === null) && (DateTime.collapsed_detect === false) ) {
      DateTime.newDetectMax();
    }
  };


  return DateTime;
}
angular
    .module('app')
    .factory('DateTime', DateTime);
