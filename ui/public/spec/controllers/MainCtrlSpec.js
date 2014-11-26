"use strict";

describe("Main Controller", function() {
  var main_ctrl;

  beforeEach(module('app'));

  beforeEach(inject(function($controller) {
    main_ctrl = $controller('MainCtrl');
  }));

  it('MainCtrl should be defined', function() {
    expect(main_ctrl).toBeDefined();
  });

});