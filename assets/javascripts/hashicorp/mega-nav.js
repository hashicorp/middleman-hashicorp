/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MIT
 */

//
// HashiCorp Mega Nav
// --------------------------------------------------

var HashiMegaNav = function() {
  var productClass = 'mega-nav-grid-item',
      productActiveClass = 'is-active',
      url = window.location.hostname,
      products = [
        'vagrant',
        'packer',
        'terraform',
        'vault',
        'nomad',
        'consul'
      ];

  for (var i = 0; i < products.length; i++) {
    if (url.indexOf(products[i]) !== -1) {
      $('.' + productClass + '-' + products[i]).addClass(productActiveClass);
    }
  }

  var $body = $('#mega-nav-body-ct');
  var $arrow = $('#mega-nav-ctrl');
  var $nav = $arrow.parent();
  var $close = $('#mega-nav-close');

  function matchesBreakpoint() {
    return window.matchMedia("(min-width: 980px)").matches;
  }

  function openNav() {
    if(matchesBreakpoint()) {
      $body.slideDown('fast');
      $nav.addClass('open');
    } else {
      $body.fadeIn('fast');
    }
  }

  function closeNav() {
    if(matchesBreakpoint()) {
      $body.slideUp('fast');
      $nav.removeClass('open');
    } else {
      $body.fadeOut('fast');
    }
  }

  function isNavOpen() {
    return $nav.hasClass('open');
  }

  $arrow.unbind().on('click', function(e) {
    e.preventDefault(); // Don't jump page to "#"

    if(isNavOpen()) {
      closeNav();
    } else {
      openNav();
    }
  });

  $close.unbind().on('click', function() {
    closeNav();
  });
}

// Handle document ready function and the turbolinks load.
$(document).on("ready turbolinks:load", HashiMegaNav);
