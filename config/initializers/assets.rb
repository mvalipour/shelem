# Be sure to restart your server when you modify this file.

Rails.application.config.tap do |config|
  config.assets.enabled = false

  # # Version of your assets, change this if you want to expire all your assets.
  # config.assets.version = '1.0'
  #
  # # Add additional assets to the asset load path.
  # # config.assets.paths << Emoji.images_path
  # # Add Yarn node_modules folder to the asset load path.
  # config.assets.paths << Rails.root.join('node_modules')
  #
  # # Precompile additional assets.
  # # application.js, application.css, and all non-JS/CSS in the app/assets
  # # folder are already added.
  # # config.assets.precompile += %w( admin.js admin.css )
  #
  # config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/
end
