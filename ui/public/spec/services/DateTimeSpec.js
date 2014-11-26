"use strict";

describe('DateTime Factory Spec', function () {

  // Load module.
  beforeEach(module('app'));

  // Check the mock service is defined.
  it('can get an instance of DateTime', inject(function(DateTime) {
    expect(DateTime).toBeDefined();
  }));

  // ********** Check Variable Init Values **********
  it('DateTime.import_min is null', inject(function(DateTime) {
    expect(DateTime.import_min).toBe(null);
  }));

  it('DateTime.import_max is null', inject(function(DateTime) {
    expect(DateTime.import_max).toBe(null);
  }));

  it('DateTime.detect_min is null', inject(function(DateTime) {
    expect(DateTime.detect_min).toBe(null);
  }));

  it('DateTime.detect_max is null', inject(function(DateTime) {
    expect(DateTime.detect_max).toBe(null);
  }));

  it('DateTime.new_filter is null', inject(function(DateTime) {
    expect(DateTime.new_filter).toBe(null);
  }));

  // ********** Check Getter Functions **********
  it('getImportMin returns import_min utc formatted', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.import_min = filter_date;
    expect(DateTime.getImportMin()).toBe(filter_date.utc().format());
  }));

  it('getImportMax returns import_max utc formatted', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.import_max = filter_date;
    expect(DateTime.getImportMax()).toBe(filter_date.utc().format());
  }));

  it('getDetectMin returns detect_min utc formatted', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.detect_min = filter_date;
    expect(DateTime.getDetectMin()).toBe(filter_date.utc().format());
  }));

  it('getDetectMax returns detect_max utc formatted', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.detect_max = filter_date;
    expect(DateTime.getDetectMax()).toBe(filter_date.utc().format());
  }));

  // ********** Check Setter Functions **********
  it('setImportMin sets import_time', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.setImportMin(filter_date);
    expect(DateTime.import_min).toBe(filter_date);
  }));

  it('setImportMax sets import_max', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.setImportMax(filter_date);
    expect(DateTime.import_max).toBe(filter_date);
  }));

  it('setDetectMin sets detect_min', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.setDetectMin(filter_date);
    expect(DateTime.detect_min).toBe(filter_date);
  }));

  it('setDetectMax sets detect_max', inject(function(DateTime) {
    var filter_date = moment().utc();
    DateTime.setDetectMax(filter_date);
    expect(DateTime.detect_max).toBe(filter_date);
  }));

  // ********** Check Filter Functions **********
  it('newDateFilter sets new_filter = true', inject(function(DateTime) {
    DateTime.new_filter = false;
    DateTime.newDateFilter();
    expect(DateTime.new_filter).toBe(true);
  }));

  it('checkDateFilter returns new_filter', inject(function(DateTime) {
    DateTime.new_filter = false;
    expect(DateTime.checkDateFilter()).toBe(false);
    DateTime.new_filter = true;
    expect(DateTime.checkDateFilter()).toBe(true);
  }));

  it('clearDateFilter sets new_filter = false', inject(function(DateTime) {
    DateTime.new_filter = true;
    DateTime.clearDateFilter();
    expect(DateTime.new_filter).toBe(false);
  }));

  it('getDateNow returns date of now', inject(function(DateTime) {
    expect(DateTime.getDateNow()).toBe(moment().utc().format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('getDateMinusHour returns date of now - 1 hour', inject(function(DateTime) {
    expect(DateTime.getDateMinusHour()).toBe(moment().utc().subtract(1, 'hours').format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('getDateMinusDay returns date of now - 1 day', inject(function(DateTime) {
    expect(DateTime.getDateMinusDay()).toBe(moment().utc().subtract(1, 'days').format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('getDateMinusWeek returns date of now - 1 week', inject(function(DateTime) {
    expect(DateTime.getDateMinusWeek()).toBe(moment().utc().subtract(1, 'weeks').format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('getDateMinusMonth returns date of now - 1 month', inject(function(DateTime) {
    expect(DateTime.getDateMinusMonth()).toBe(moment().utc().subtract(1, 'months').format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('getDateMinusYear returns date of now - 1 year', inject(function(DateTime) {
    expect(DateTime.getDateMinusYear()).toBe(moment().utc().subtract(1, 'years').format('MM-DD-YYYYTHH:mm:ss'));
  }));

  it('addDateFilter set new_filter = import_min', inject(function(DateTime) {
    var new_date = {
      'type': 'import_min',
      'datetime': '01012000121212'
    };
    DateTime.addDateFilter(new_date);

    var filter_date = moment().utc();

    filter_date.utc().date('01');
    filter_date.utc().month('01');
    filter_date.utc().year('2000');
    filter_date.utc().hours('12');
    filter_date.utc().minutes('12');
    filter_date.utc().seconds('12');

    expect(DateTime.import_min.utc().format()).toEqual(filter_date.utc().format());
  }));

  it('addDateFilter set new_filter = import_max', inject(function(DateTime) {
    var new_date = {
      'type': 'import_max',
      'datetime': '01012000121212'
    };
    DateTime.addDateFilter(new_date);

    var filter_date = moment().utc();

    filter_date.utc().date('01');
    filter_date.utc().month('01');
    filter_date.utc().year('2000');
    filter_date.utc().hours('12');
    filter_date.utc().minutes('12');
    filter_date.utc().seconds('12');

    expect(DateTime.import_max.utc().format()).toEqual(filter_date.utc().format());
  }));

  it('addDateFilter set new_filter = detect_min', inject(function(DateTime) {
    var new_date = {
      'type': 'detect_min',
      'datetime': '01012000121212'
    };
    DateTime.addDateFilter(new_date);

    var filter_date = moment().utc();

    filter_date.utc().date('01');
    filter_date.utc().month('01');
    filter_date.utc().year('2000');
    filter_date.utc().hours('12');
    filter_date.utc().minutes('12');
    filter_date.utc().seconds('12');

    expect(DateTime.detect_min.utc().format()).toEqual(filter_date.utc().format());
  }));

  it('addDateFilter set new_filter = detect_max', inject(function(DateTime) {
    var new_date = {
      'type': 'detect_max',
      'datetime': '01012000121212'
    };
    DateTime.addDateFilter(new_date);

    var filter_date = moment().utc();

    filter_date.utc().date('01');
    filter_date.utc().month('01');
    filter_date.utc().year('2000');
    filter_date.utc().hours('12');
    filter_date.utc().minutes('12');
    filter_date.utc().seconds('12');

    expect(DateTime.detect_max.utc().format()).toEqual(filter_date.utc().format());
  }));

  it('clearImportMin sets import_min = null', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.import_min = datetime;
    expect(DateTime.import_min.utc().format()).toBe(datetime.utc().format());
    DateTime.clearImportMin();
    expect(DateTime.import_min).toBe(null);
  }));

  it('clearImportMax sets import_max = null', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.import_max = datetime;
    expect(DateTime.import_max.utc().format()).toBe(datetime.utc().format());
    DateTime.clearImportMax();
    expect(DateTime.import_max).toBe(null);
  }));

  it('clearDetectMin sets detect_min = null', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.detect_min = datetime;
    expect(DateTime.detect_min.utc().format()).toBe(datetime.utc().format());
    DateTime.clearDetectMin();
    expect(DateTime.detect_min).toBe(null);
  }));

  it('clearDetectMax sets detect_max = null', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.detect_max = datetime;
    expect(DateTime.detect_max.utc().format()).toBe(datetime.utc().format());
    DateTime.clearDetectMax();
    expect(DateTime.detect_max).toBe(null);
  }));


  it('newImportMin sets import_min', inject(function(DateTime) {
    DateTime.import_min = null;
    expect(DateTime.import_min).toBe(null);

    var datetime = moment().utc();
    DateTime.newImportMin(datetime);
    expect(DateTime.import_min.utc().format()).toBe(datetime.utc().format());
  }));

  it('newImportMax sets import_max', inject(function(DateTime) {
    DateTime.import_max = null;
    expect(DateTime.import_max).toBe(null);

    var datetime = moment().utc();
    DateTime.newImportMax(datetime);
    expect(DateTime.import_max.utc().format()).toBe(datetime.utc().format());
  }));

  it('newDetectMin sets detect_min', inject(function(DateTime) {
    DateTime.detect_min = null;
    expect(DateTime.detect_min).toBe(null);

    var datetime = moment().utc();
    DateTime.newDetectMin(datetime);
    expect(DateTime.detect_min.utc().format()).toBe(datetime.utc().format());
  }));

  it('newDetectMax sets detect_max', inject(function(DateTime) {
    DateTime.detect_max = null;
    expect(DateTime.detect_max).toBe(null);

    var datetime = moment().utc();
    DateTime.newDetectMax(datetime);
    expect(DateTime.detect_max.utc().format()).toBe(datetime.utc().format());
  }));

  it('initialImportMin sets import_min to now minus 30 days', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.import_min = datetime;
    expect(DateTime.import_min.utc().format()).toBe(datetime.utc().format());

    DateTime.initialImportMin();
    expect(DateTime.import_min.utc().format()).toBe(moment().utc().subtract(30, 'days').format());
  }));

  it('initialDetectMin sets detect_min to now minus 30 days', inject(function(DateTime) {
    var datetime = moment().utc();
    DateTime.detect_min = datetime;
    expect(DateTime.detect_min.utc().format()).toBe(datetime.utc().format());

    DateTime.initialDetectMin();
    expect(DateTime.detect_min.utc().format()).toBe(moment().utc().subtract(30, 'days').format());
  }));


});