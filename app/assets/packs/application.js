require('stylesheets');

var Clipboard = require('clipboard');

function ready(fn) {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready(() => new Clipboard('.clipboard-btn'));
