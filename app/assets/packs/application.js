require('stylesheets');
require('javascripts/cable')
require('javascripts/vue')

const ready = require('javascripts/ready')

var Clipboard = require('clipboard');

ready(() => new Clipboard('.clipboard-btn'));
