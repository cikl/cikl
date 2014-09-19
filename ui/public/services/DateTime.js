function DateTime () {

  var DateTime = {};

  // Filters
  DateTime.import_min = null;
  DateTime.import_max = null;
  DateTime.detect_min = null;
  DateTime.detect_max = null;

  // Filter collapse
  DateTime.new_filter = null;

  // Formatted getter functions
  DateTime.getImportMin = function () {
    if (DateTime.import_min) {
      return DateTime.import_min.utc().format();
    }
    else {
      return null;
    }
  };
  DateTime.getImportMax = function () {
    if (DateTime.import_max) {
      return DateTime.import_max.utc().format();
    }
    else {
      return null;
    }
  };
  DateTime.getDetectMin = function () {
    if (DateTime.detect_min) {
      return DateTime.detect_min.utc().format();
    }
    else {
      return null;
    }
  };
  DateTime.getDetectMax = function () {
    if (DateTime.detect_max) {
      return DateTime.detect_max.utc().format();
    }
    else {
      return null;
    }
  };

  // Setter functions
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

  // Filter functions
  DateTime.newDateFilter = function () {
    DateTime.new_filter = true;
  };
  DateTime.checkDateFilter = function () {
    return DateTime.new_filter;
  };
  DateTime.clearDateFilter = function () {
    DateTime.new_filter = false;
  };
  DateTime.getDateNow = function () {
    return moment().utc().format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.getDateMinusHour = function () {
    return moment().utc().subtract(1, 'hours').format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.getDateMinusDay = function () {
    return moment().utc().subtract(1, 'days').format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.getDateMinusWeek = function () {
    return moment().utc().subtract(1, 'weeks').format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.getDateMinusMonth = function () {
    return moment().utc().subtract(1, 'months').format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.getDateMinusYear = function () {
    return moment().utc().subtract(1, 'years').format('MM-DD-YYYYTHH:mm:ss');
  };
  DateTime.addDateFilter = function (filter) {
    if (filter) {
      if (filter.type) {
        var filter_date = moment().utc();


        if (filter.datetime) {
          // Strip out everything excepts numbers
          var date = filter.datetime.replace(/\D/g, '');

          // Parse out the day, month, and year
          if (date.length == 14) {
            var month = parseInt(date[0] + date[1]) - 1;
            var day = parseInt(date[2] + date[3]);
            var year = parseInt(date[4] + date[5] + date[6] + date[7]);
            var hours = parseInt(date[8] + date[9]);
            var minutes = parseInt(date[10] + date[11]);
            var seconds = parseInt(date[12] + date[13]);

            if (day < 32 && day > 0) {
              filter_date.utc().date(day);
            }
            if (month < 13 && month > 0) {
              filter_date.utc().month(month);
            }
            if (year <= filter_date.year() && year > 1900) {
              filter_date.utc().year(year);
            }
            if (hours < 24 && hours >= 0) {
              filter_date.utc().hours(hours);
            }
            if (minutes < 60 && minutes >= 0) {
              filter_date.utc().minutes(minutes);
            }
            if (seconds < 60 && seconds >= 0) {
              filter_date.utc().seconds(seconds);
            }

            if (filter.type === 'import_min') {
              DateTime.setImportMin(filter_date);
            }
            else if (filter.type === 'import_max') {
              DateTime.setImportMax(filter_date);
            }
            else if (filter.type === 'detect_min') {
              DateTime.setDetectMin(filter_date);
            }
            else if (filter.type === 'detect_max') {
              DateTime.setDetectMax(filter_date);
            }
            else {
              console.log('Filter type invalid!');
            }
          }
          else {
            console.log('Filter datetime is null!');
          }
        }

      }// END if (filter.type)
      else {
        console.log('Filter is null!');
      }
    }// END if (filter)

  };

  // Get epoch times for URL encoding
  DateTime.getImportMinEpoch = function() {
    if (DateTime.import_min === null) {
      return null;
    }
    else {
      return (DateTime.import_min.utc());
    }
  };
  DateTime.getImportMaxEpoch = function() {
    if (DateTime.import_max === null) {
      return null;
    }
    else {
      return (DateTime.import_max.utc());
    }
  };
  DateTime.getDetectMinEpoch = function() {
    if (DateTime.detect_min === null) {
      return null;
    }
    else {
      return (DateTime.detect_min.utc());
    }
  };
  DateTime.getDetectMaxEpoch = function() {
    if (DateTime.detect_max === null) {
      return null;
    }
    else {
      return (DateTime.detect_max.utc());
    }
  };

  // Parse URL epoch times back to moments
  DateTime.setImportMinFromEpoch = function(date) {
    if (date === null) {
      DateTime.import_min = null;
    }
    else {
      var new_date = moment.utc(date);
      DateTime.setImportMin(new_date);
    }
  };
  DateTime.setImportMaxFromEpoch = function(date) {
    if (date === null) {
      DateTime.import_max = null;
    }
    else {
      var new_date = moment.utc(date);
      DateTime.setImportMax(new_date);
    }
  };
  DateTime.setDetectMinFromEpoch = function(date) {
    if (date === null) {
      DateTime.detect_min = null;
    }
    else {
      var new_date = moment.utc(date);
      DateTime.setDetectMin(new_date);
    }
  };
  DateTime.setDetectMaxFromEpoch = function(date) {
    if (date === null) {
      DateTime.detect_max = null;
    }
    else {
      var new_date = moment.utc(date);
      DateTime.setDetectMax(new_date);
    }
  };

  // Filter clear functions
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

  // Set filters to new moments in utc
  DateTime.newImportMin = function () {
    DateTime.import_min = moment().utc();
  };
  DateTime.newImportMax = function () {
    DateTime.import_max = moment().utc();
  };
  DateTime.newDetectMin = function () {
    DateTime.detect_min = moment().utc();
  };
  DateTime.newDetectMax = function () {
    DateTime.detect_max = moment().utc();
  };

  // Initialize filter min dates to minus 30 days
  DateTime.initialImportMin = function () {
    DateTime.import_min.utc().subtract(30, 'days');
  };
  DateTime.initialDetectMin = function () {
    DateTime.detect_min.utc().subtract(30, 'days');
  };

  return DateTime;
}
angular
    .module('app')
    .factory('DateTime', DateTime);
