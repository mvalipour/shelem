require('stylesheets');
require('javascripts/cable')

const ready = require('javascripts/ready')

var Clipboard = require('clipboard');

ready(() => new Clipboard('.clipboard-btn'));
