const { environment } = require('@rails/webpacker')

environment.config.merge({
  resolve: {
    alias: {
      vue: 'vue/dist/vue.min.js'
    }
  }
});

module.exports = environment
