#
# foodsoft-translation - foodsoft instance connected to localeapp
#                        translators can use this instance to work on translations
#                        it should be used with a dummy database with data that
#                        enables translators to access all functionality
#
Foodsoft::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is reloaded between requests, so that translations are picked up
  config.cache_classes = false

  # Full error reports are disabled and caching is turned off
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  #config.force_ssl = true

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.active_support.deprecation = :notify

  # Use sendmail to avoid ssl cert problems
  config.action_mailer.delivery_method = :sendmail

  # If you want to use online payment, you need to enter details here
  config.ideal_mollie.partner_id = 1124741
  config.ideal_mollie.profile_key = '424DACA5'
  config.ideal_mollie.test_mode = true # don't do real payments here
end
