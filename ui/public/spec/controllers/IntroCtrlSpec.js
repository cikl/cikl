"use strict";

describe("Intro Controller", function() {

  var intro_ctrl;

  beforeEach(module('app'));

  beforeEach(inject(function($controller) {
    intro_ctrl = $controller('IntroCtrl');
  }));

  it('IntroCtrl should be defined', function() {
    expect(intro_ctrl).toBeDefined();
  });

});