'use strict'

/**
 * Wrapper for segment's track function that will track multiple elements,
 * normalize parameters, and easily switch between tracking links or events.
 * @param  {String} selector - query selector, multi element compatible
 * @param  {Function} cb - optional function that should return params, and will receive the element as a parameter
 * @param  {Boolean} [link] - if true, tracks a link click
 */
function track(selector, cb, link) {
  each(document.querySelectorAll(selector), function(el) {
    var params = cb
    if (typeof cb === 'function') {
      params = cb(el)
    }
    var event = params.event
    delete params.event
    if (link) {
      analytics.trackLink(el, event, params)
    } else {
      el.addEventListener('click', function() {
        analytics.track(event, params)
      })
    }
  })
}

/**
 * Iterates through a NodeList, not built-in for all browsers.
 * (https://developer.mozilla.org/en-US/docs/Web/API/NodeList)
 * @param  {NodeList} list a NodeList instance
 * @param  {Function} cb a function to execute for each node
 */
function each(list, cb) {
  for (var i = 0; i < list.length; i++) {
    cb(list[i], i)
  }
}

// Expose as commonjs for module bundlers if needed
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { track: track }
}
