/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MIT
 */

// HashiSidebar is the sidebar implementation for mobile websites. It
// appears at a configurable breakpoint in the CSS.
var HashiSidebar = function() {
  var $sidebar = $('.sidebar');
  var $toggle = $('.navbar-toggle');
  var $overlay = $('.sidebar-overlay');

  function sidebarActive() {
    return $sidebar.hasClass('open');
  }

  function hideSidebar() {
    if(sidebarActive()) {
      $sidebar.removeClass('open');
      $overlay.removeClass('active');
    }
  }

  // Hide the sidebar when the user clicks on the overlay. The overlay is
  // only "clickable" when it's active.
  $overlay.unbind().on('click', function(e){
    hideSidebar();
  });

  // Show the sidebar when the user clicks the hamburger menu.
  $toggle.unbind().on('click', function(e) {
    e.preventDefault(); // Don't jump page to "#"

    // Only activate the sidebar if it's not already active. Since these
    // are class selectors, it's possible that we are watching multiple
    // elements.
    if(!sidebarActive()) {
      $overlay.addClass('active');
      $sidebar.toggleClass('open');
    }
  });
}

// Handle document ready function and the turbolinks load.
$(document).on("ready turbolinks:load", HashiSidebar);
