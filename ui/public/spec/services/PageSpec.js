"use strict";

describe('Page Factory Spec', function () {

  // Load module.
  beforeEach(module('app'));

  // Check the mock service is defined.
  it('can get an instance of Page', inject(function(Page) {
    expect(Page).toBeDefined();
  }));

  // ********** Check Variable Init Values **********
  it('Page.first_page is null', inject(function(Page) {
    expect(Page.first_page).toBe(null);
  }));

  it('Page.prev_page is null', inject(function(Page) {
    expect(Page.prev_page).toBe(null);
  }));

  it('Page.current_page is null', inject(function(Page) {
    expect(Page.current_page).toBe(null);
  }));

  it('Page.next_page is null', inject(function(Page) {
    expect(Page.next_page).toBe(null);
  }));

  it('Page.last_page is null', inject(function(Page) {
    expect(Page.last_page).toBe(null);
  }));

  it('Page.total_items is null', inject(function(Page) {
    expect(Page.total_items).toBe(null);
  }));

  it('Page.items_per_page is null', inject(function(Page) {
    expect(Page.items_per_page).toBe(null);
  }));

  it('Page.max_size is 10', inject(function(Page) {
    expect(Page.max_size).toBe(10);
  }));

  it('Page.start is null', inject(function(Page) {
    expect(Page.start).toBe(null);
  }));

  it('Page.end is null', inject(function(Page) {
    expect(Page.end).toBe(null);
  }));

  // ********** Check Getter Functions **********
  it('getFirstPage returns first_page', inject(function(Page) {
    Page.first_page = 1;
    expect(Page.getFirstPage()).toBe(1);
  }));

  it('getPrevPage returns prev_page', inject(function(Page) {
    Page.prev_page = 1;
    expect(Page.getPrevPage()).toBe(1);
  }));

  it('getCurrentPage returns current_page', inject(function(Page) {
    Page.current_page = 1;
    expect(Page.getCurrentPage()).toBe(1);
  }));

  it('getNextPage returns next_page', inject(function(Page) {
    Page.next_page = 1;
    expect(Page.getNextPage()).toBe(1);
  }));

  it('getLastPage returns last_page', inject(function(Page) {
    Page.last_page = 1;
    expect(Page.getLastPage()).toBe(1);
  }));

  it('getTotalItems returns total_items', inject(function(Page) {
    Page.total_items = 100;
    expect(Page.getTotalItems()).toBe(100);
  }));

  it('getItemsPerPage returns items_per_page', inject(function(Page) {
    Page.items_per_page = 20;
    expect(Page.getItemsPerPage()).toBe(20);
  }));

  it('getMaxSize returns max_size', inject(function(Page) {
    expect(Page.getMaxSize()).toBe(10);
  }));

  it('getShowingStart returns start', inject(function(Page) {
    Page.start = 1;
    expect(Page.getShowingStart()).toBe(1);
  }));

  it('getShowingEnd returns end', inject(function(Page) {
    Page.end = 1;
    expect(Page.getShowingEnd()).toBe(1);
  }));

  // ********** Check Setter Functions **********
  it('setCurrentPage sets current_page', inject(function(Page) {
    Page.setCurrentPage(1);
    expect(Page.current_page).toBe(1);
  }));

  it('setTotalItems sets total_items', inject(function(Page) {
    Page.setTotalItems(100);
    expect(Page.total_items).toBe(100);
  }));

  it('setItemsPerPage sets items_per_page', inject(function(Page) {
    Page.setItemsPerPage(20);
    expect(Page.items_per_page).toBe(20);
  }));

  it('setMaxSize sets max_size', inject(function(Page) {
    Page.setMaxSize(20);
    expect(Page.max_size).toBe(20);
  }));

  it('setShowingStart when total_items = 0, sets start = 0', inject(function(Page) {
    Page.total_items = 0;
    Page.setShowingStart(1);
    expect(Page.start).toBe(0);
  }));

  it('setShowingStart when total_items > 0, sets start', inject(function(Page) {
    Page.total_items = 1;
    Page.setShowingStart(1);
    expect(Page.start).toBe(1);
  }));

  it('setShowingEnd when last_page = null, sets end = total_items', inject(function(Page) {
    Page.last_page = null;
    Page.total_items = 100;
    Page.setShowingEnd();
    expect(Page.end).toBe(100);
  }));

  it('setShowingEnd when last_page = current_page, sets end = total_items', inject(function(Page) {
    Page.last_page = 5;
    Page.current_page = 5;
    Page.total_items = 100;
    Page.setShowingEnd();
    expect(Page.end).toBe(100);
  }));

  it('setShowingEnd when last_page != current_page, sets end = (start + items_per_page -1)', inject(function(Page) {
    Page.last_page = 5;
    Page.current_page = 2;
    Page.total_items = 100;
    Page.start = 21;
    Page.items_per_page = 20;
    Page.setShowingEnd();
    expect(Page.end).toBe(40);
  }));

  // ********** Check Boolean Functions **********
  it('checkCurrentPage when true', inject(function(Page) {
    Page.current_page = 1;
    expect(Page.checkCurrentPage(1)).toBe(true);
  }));

  it('checkCurrentPage when false', inject(function(Page) {
    Page.current_page = 1;
    expect(Page.checkCurrentPage(2)).toBe(false);
  }));

  it('isShowingSelected when true', inject(function(Page) {
    Page.items_per_page = 20;
    expect(Page.isShowingSelected(20)).toBe(true);
  }));

  it('isShowingSelected when false', inject(function(Page) {
    Page.items_per_page = 20;
    expect(Page.isShowingSelected(21)).toBe(false);
  }));

  it('isVisible when current_page = 1, total_items = 400, items_per_page = 20', inject(function(Page) {
    Page.current_page = 1;
    Page.items_per_page = 20;
    Page.total_items = 400;
    expect(Page.isVisible(1)).toBe(true);
    expect(Page.isVisible(2)).toBe(true);
    expect(Page.isVisible(3)).toBe(true);
    expect(Page.isVisible(4)).toBe(true);
    expect(Page.isVisible(5)).toBe(true);
    expect(Page.isVisible(6)).toBe(true);
    expect(Page.isVisible(7)).toBe(true);
    expect(Page.isVisible(8)).toBe(true);
    expect(Page.isVisible(9)).toBe(true);
    expect(Page.isVisible(10)).toBe(true);
    expect(Page.isVisible(11)).toBe(true);
    expect(Page.isVisible(12)).toBe(false);
  }));

  it('isVisible when current_page = 6, total_items = 400, items_per_page = 20', inject(function(Page) {
    Page.current_page = 6;
    Page.items_per_page = 20;
    Page.total_items = 400;
    expect(Page.isVisible(1)).toBe(true);
    expect(Page.isVisible(2)).toBe(true);
    expect(Page.isVisible(3)).toBe(true);
    expect(Page.isVisible(4)).toBe(true);
    expect(Page.isVisible(5)).toBe(true);
    expect(Page.isVisible(6)).toBe(true);
    expect(Page.isVisible(7)).toBe(true);
    expect(Page.isVisible(8)).toBe(true);
    expect(Page.isVisible(9)).toBe(true);
    expect(Page.isVisible(10)).toBe(true);
    expect(Page.isVisible(11)).toBe(true);
    expect(Page.isVisible(12)).toBe(false);
  }));

  it('isVisible when current_page = 7, total_items = 400, items_per_page = 20', inject(function(Page) {
    Page.current_page = 7;
    Page.items_per_page = 20;
    Page.total_items = 400;
    expect(Page.isVisible(1)).toBe(false);
    expect(Page.isVisible(2)).toBe(true);
    expect(Page.isVisible(3)).toBe(true);
    expect(Page.isVisible(4)).toBe(true);
    expect(Page.isVisible(5)).toBe(true);
    expect(Page.isVisible(6)).toBe(true);
    expect(Page.isVisible(7)).toBe(true);
    expect(Page.isVisible(8)).toBe(true);
    expect(Page.isVisible(9)).toBe(true);
    expect(Page.isVisible(10)).toBe(true);
    expect(Page.isVisible(11)).toBe(true);
    expect(Page.isVisible(12)).toBe(true);
    expect(Page.isVisible(13)).toBe(false);
  }));

  it('isVisible when current_page = 8, total_items = 241, items_per_page = 20', inject(function(Page) {
    Page.current_page = 8;
    Page.items_per_page = 20;
    Page.total_items = 241;
    expect(Page.isVisible(2)).toBe(false);
    expect(Page.isVisible(3)).toBe(true);
    expect(Page.isVisible(4)).toBe(true);
    expect(Page.isVisible(5)).toBe(true);
    expect(Page.isVisible(6)).toBe(true);
    expect(Page.isVisible(7)).toBe(true);
    expect(Page.isVisible(8)).toBe(true);
    expect(Page.isVisible(9)).toBe(true);
    expect(Page.isVisible(10)).toBe(true);
    expect(Page.isVisible(11)).toBe(true);
    expect(Page.isVisible(12)).toBe(true);
    expect(Page.isVisible(13)).toBe(true);
    expect(Page.isVisible(14)).toBe(true);
  }));

  // ********** Check Display Update Functions **********
  it('getPages when total_items = 0, items_per_page = 20', inject(function(Page) {
    Page.items_per_page = 20;
    Page.total_items = 0;
    var pages = Page.getPages();
    expect(pages.length).toBe(0);
  }));

  it('getPages when total_items = 1, items_per_page = 20', inject(function(Page) {
    Page.items_per_page = 20;
    Page.total_items = 1;
    var pages = Page.getPages();
    expect(pages.length).toBe(1);
    expect(pages).toContain(1);
  }));

  it('getPages when total_items = 100, items_per_page = 20', inject(function(Page) {
    Page.items_per_page = 20;
    Page.total_items = 100;
    var pages = Page.getPages();
    expect(pages.length).toBe(5);
    expect(pages).toContain(1);
    expect(pages).toContain(2);
    expect(pages).toContain(3);
    expect(pages).toContain(4);
    expect(pages).toContain(5);
  }));

  it('getPages when total_items = 101, items_per_page = 20', inject(function(Page) {
    Page.items_per_page = 20;
    Page.total_items = 101;
    var pages = Page.getPages();
    expect(pages.length).toBe(6);
    expect(pages).toContain(1);
    expect(pages).toContain(2);
    expect(pages).toContain(3);
    expect(pages).toContain(4);
    expect(pages).toContain(5);
    expect(pages).toContain(6);
  }));

  it('getPages when total_items = 0, items_per_page = 100', inject(function(Page) {
    Page.items_per_page = 100;
    Page.total_items = 0;
    var pages = Page.getPages();
    expect(pages.length).toBe(0);
  }));

  it('getPages when total_items = 1, items_per_page = 100', inject(function(Page) {
    Page.items_per_page = 100;
    Page.total_items = 1;
    var pages = Page.getPages();
    expect(pages.length).toBe(1);
    expect(pages).toContain(1);
  }));

  it('getPages when total_items = 100, items_per_page = 100', inject(function(Page) {
    Page.items_per_page = 100;
    Page.total_items = 100;
    var pages = Page.getPages();
    expect(pages.length).toBe(1);
    expect(pages).toContain(1);
  }));

  it('getPages when total_items = 101, items_per_page = 100', inject(function(Page) {
    Page.items_per_page = 100;
    Page.total_items = 101;
    var pages = Page.getPages();
    expect(pages.length).toBe(2);
    expect(pages).toContain(1);
    expect(pages).toContain(2);
  }));

  it('updatePage when new page = 1, total_items = 1, items_per_page = 20', inject(function(Page) {
    Page.current_page = 8;
    Page.items_per_page = 20;
    Page.total_items = 1;
    Page.updatePage(1);
    expect(Page.first_page).toBe(null);
    expect(Page.prev_page).toBe(null);
    expect(Page.current_page).toBe(1);
    expect(Page.next_page).toBe(null);
    expect(Page.last_page).toBe(null);
  }));

  it('updatePage when new page = 1, total_items = 21, items_per_page = 20', inject(function(Page) {
    Page.current_page = 8;
    Page.items_per_page = 20;
    Page.total_items = 21;
    Page.updatePage(1);
    expect(Page.first_page).toBe(null);
    expect(Page.prev_page).toBe(null);
    expect(Page.current_page).toBe(1);
    expect(Page.next_page).toBe(2);
    expect(Page.last_page).toBe(2);
  }));

  it('updatePage when new page = 2, total_items = 21, items_per_page = 20', inject(function(Page) {
    Page.current_page = 8;
    Page.items_per_page = 20;
    Page.total_items = 21;
    Page.updatePage(2);
    expect(Page.first_page).toBe(1);
    expect(Page.prev_page).toBe(1);
    expect(Page.current_page).toBe(2);
    expect(Page.next_page).toBe(null);
    expect(Page.last_page).toBe(null);
  }));

  it('updatePage when new page = 2, total_items = 41, items_per_page = 20', inject(function(Page) {
    Page.current_page = 8;
    Page.items_per_page = 20;
    Page.total_items = 41;
    Page.updatePage(2);
    expect(Page.first_page).toBe(1);
    expect(Page.prev_page).toBe(1);
    expect(Page.current_page).toBe(2);
    expect(Page.next_page).toBe(3);
    expect(Page.last_page).toBe(3);
  }));
});