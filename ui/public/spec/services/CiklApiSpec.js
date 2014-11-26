"use strict";

describe("CiklApi Factory Spec", function() {

  // Load module.
  beforeEach(module('app'));

  // Check the mock service is defined.
  it('can get an instance of CiklApi', inject(function(CiklApi) {
    expect(CiklApi).toBeDefined();
  }));

  // ********** Check Variable Init Values **********
  it('CiklApi.order_by is null', inject(function(CiklApi) {
    expect(CiklApi.order_by).toBe(null);
  }));

  it('CiklApi.order is null', inject(function(CiklApi) {
    expect(CiklApi.order).toBe(null);
  }));

  it('CiklApi.term is null', inject(function(CiklApi) {
    expect(CiklApi.term).toBe(null);
  }));

  it('CiklApi.type is null', inject(function(CiklApi) {
    expect(CiklApi.type).toBe(null);
  }));

  it('CiklApi.query is null', inject(function(CiklApi) {
    expect(CiklApi.query).toBe(null);
  }));

  // ********** Check Getter Functions **********
  it('getOrderBy returns order_by', inject(function(CiklApi) {
    CiklApi.order_by = 'import_time';
    expect(CiklApi.getOrderBy()).toBe('import_time');
  }));

  it('getOrder returns order_by', inject(function(CiklApi) {
    CiklApi.order = 'asc';
    expect(CiklApi.getOrder()).toBe('asc');
  }));

  it('getTerm returns term', inject(function(CiklApi) {
    CiklApi.term = 'yahoo.com';
    expect(CiklApi.getTerm()).toBe('yahoo.com');
  }));

  it('getType returns type', inject(function(CiklApi) {
    CiklApi.term = 'fqdn';
    expect(CiklApi.getTerm()).toBe('fqdn');
  }));

  it('getQuery returns Query', inject(function(CiklApi) {
    CiklApi.query = 'query';
    expect(CiklApi.getQuery()).toBe('query');
  }));

  // ********** Check Setter Functions **********
  it('setOrderBy sets order_by', inject(function(CiklApi) {
     CiklApi.setOrderBy('import_time');
    expect(CiklApi.order_by).toBe('import_time');
  }));

  it('setOrder sets order_by', inject(function(CiklApi) {
    CiklApi.setOrder('asc');
    expect(CiklApi.order).toBe('asc');
  }));

  it('setTerm sets term', inject(function(CiklApi) {
    CiklApi.setTerm('yahoo.com');
    expect(CiklApi.term).toBe('yahoo.com');
  }));

  it('setType sets type', inject(function(CiklApi) {
    CiklApi.setTerm('fqdn');
    expect(CiklApi.term).toBe('fqdn');
  }));

  it('isAsc checks if order is asc', inject(function(CiklApi) {
    CiklApi.order = 'desc';
    expect(CiklApi.isAsc()).toBe(false);
    CiklApi.order = 'asc';
    expect(CiklApi.isAsc()).toBe(true);
  }));

  it('isDesc checks if order is desc', inject(function(CiklApi) {
    CiklApi.order = 'desc';
    expect(CiklApi.isDesc()).toBe(true);
    CiklApi.order = 'asc';
    expect(CiklApi.isDesc()).toBe(false);
  }));

  it('isImport checks if order_by is import_time', inject(function(CiklApi) {
    CiklApi.order_by = 'detect_time';
    expect(CiklApi.isImport()).toBe(false);
    CiklApi.order_by = 'import_time';
    expect(CiklApi.isImport()).toBe(true);
  }));

  it('isDetect checks if order_by is detect_time', inject(function(CiklApi) {
    CiklApi.order_by = 'import_time';
    expect(CiklApi.isDetect()).toBe(false);
    CiklApi.order_by = 'detect_time';
    expect(CiklApi.isDetect()).toBe(true);
  }));

  it('sortDetect when order_by = import_time', inject(function(CiklApi) {
    CiklApi.order_by = 'import_time';
    CiklApi.sortDetect();
    expect(CiklApi.order).toBe('desc');
    expect(CiklApi.order_by).toBe('detect_time');
  }));

  it('sortDetect when order_by = detect_time & order = desc', inject(function(CiklApi) {
    CiklApi.order_by = 'detect_time';
    CiklApi.order = 'desc';
    CiklApi.sortDetect();
    expect(CiklApi.order).toBe('asc');
    expect(CiklApi.order_by).toBe('detect_time');
  }));

  it('sortDetect when order_by = detect_time & order = asc', inject(function(CiklApi) {
    CiklApi.order_by = 'detect_time';
    CiklApi.order = 'asc';
    CiklApi.sortDetect();
    expect(CiklApi.order).toBe('desc');
    expect(CiklApi.order_by).toBe('detect_time');
  }));

  it('sortImport when order_by = detect_time', inject(function(CiklApi) {
    CiklApi.order_by = 'detect_time';
    CiklApi.sortImport();
    expect(CiklApi.order).toBe('desc');
    expect(CiklApi.order_by).toBe('import_time');
  }));

  it('sortImport when order_by = import_time & order = desc', inject(function(CiklApi) {
    CiklApi.order_by = 'import_time';
    CiklApi.order = 'desc';
    CiklApi.sortImport();
    expect(CiklApi.order).toBe('asc');
    expect(CiklApi.order_by).toBe('import_time');
  }));

  it('sortImport when order_by = import_time & order = asc', inject(function(CiklApi) {
    CiklApi.order_by = 'import_time';
    CiklApi.order = 'asc';
    CiklApi.sortImport();
    expect(CiklApi.order).toBe('desc');
    expect(CiklApi.order_by).toBe('import_time');
  }));

  it('queryApi', inject(function(CiklApi) {

  }));




//  beforeEach(module(function($provide) {
//    $provide.value("myDependentService", serviceThatsActuallyASpyObject);
//  }));
//
//  beforeEach(inject(function (_CiklApi_, $httpBackend) {
//    CiklApi = _CiklApi_;
//    httpBackend = $httpBackend;
//  }));

//  it("should do something", function () {
//    httpBackend.whenGET("http://localhost:8080/user/yoitsnate/submitted.json").respond({
//      data: {
//        children: [
//          {
//            data: {
//              subreddit: "golang"
//            }
//          },
//          {
//            data: {
//              subreddit: "javascript"
//            }
//          },
//          {
//            data: {
//              subreddit: "golang"
//            }
//          },
//          {
//            data: {
//              subreddit: "javascript"
//            }
//          }
//        ]
//      }
//    });
//    redditService.getSubredditsSubmittedToBy("yoitsnate").then(function(subreddits) {
//      expect(subreddits).toEqual(["golang", "javascript"]);
//    });
//    httpBackend.flush();

});