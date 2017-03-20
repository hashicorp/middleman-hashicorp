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

  var dropDownBreakpoint = window.matchMedia("(min-width: 980px)");

  function megaNavModal() {
    $('#mega-nav-body-ct').attr({
      role: 'dialog',
      tabindex: -1
    });

    $('#mega-nav-ctrl').on('click.megaNav', function(){
      $('#mega-nav-body-ct').modal({
        backdrop: false
      });
    });

    $('#mega-nav-close').on('click.megaNav', function() {
      $('#mega-nav-body-ct').modal('hide');
    });
  }

  function megaNavModalDestroy() {
    $('#mega-nav-ctrl').off('click.megaNav');
    $('#mega-nav-close').off('click.megaNav');
    $('#mega-nav-body-ct')
      .modal('hide')
      .removeAttr('role tabindex style')
      .data('bs.modal', null);
  }

  function megaNavDropDown() {
    $('#mega-nav-ctrl').attr('data-toggle', 'dropdown');
  }

  function megaNavDropDownDestroy() {
    $('#mega-nav-ctrl').parent().removeClass('open');
    $('#mega-nav-ctrl').removeAttr('data-toggle aria-expanded');
    $('#mega-nav-body-ct').removeAttr('aria-labelledby');
  }

  function handleDropDownBreakpoint(breakpoint) {
    if (breakpoint.matches) {
      megaNavModalDestroy();
      megaNavDropDown();
    } else {
      megaNavDropDownDestroy();
      megaNavModal();
    }
  }

  dropDownBreakpoint.addListener(handleDropDownBreakpoint);
  handleDropDownBreakpoint(dropDownBreakpoint);
}

// Handle document ready function and the turbolinks load.
$(document).on("ready turbolinks:load", HashiMegaNav);
