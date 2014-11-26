"use strict";

describe('UrlBuilder Factory Spec', function () {

  // Load module.
  beforeEach(module('app'));

  // Check the mock service is defined.
  it('can get an instance of UrlBuilder', inject(function(UrlBuilder) {
    expect(UrlBuilder).toBeDefined();
  }));

  // ********** Check Variable Init Values **********
  it('UrlBuilder.root is window.location.origin', inject(function(UrlBuilder) {
    expect(UrlBuilder.root).toBe(window.location.origin);
  }));

  it('UrlBuilder.path is null', inject(function(UrlBuilder) {
    expect(UrlBuilder.path).toBe(null);
  }));

});