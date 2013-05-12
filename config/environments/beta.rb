#
# foodsoft-beta - staging server where users and developers are able to test
#                 pre-production versions working on the real database
#

Foodsoft::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # development settings, except those compromising security
  config.cache_classes = false
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  config.assets.compile = true
  config.assets.compress = false
  config.assets.debug = true
  config.assets.digest = true

  config.whiny_nils = true
  config.active_support.deprecation = :log, :notify
  config.active_record.mass_assignment_sanitizer = :strict

  # # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  #config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Use sendmail to avoid ssl cert problems
  config.action_mailer.delivery_method = :sendmail

  # If you want to use online payment, you need to enter details here
  config.ideal_mollie.partner_id = 1124741
  config.ideal_mollie.profile_key = '424DACA5'
  config.ideal_mollie.test_mode = true
end
