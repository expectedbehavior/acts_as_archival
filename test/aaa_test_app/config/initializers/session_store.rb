# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_aaa_test_app_session',
  :secret      => '93c22f5de7b9772cf763280a377417106dd85cc78ac4f4ab2f5813097035efa6272ebd92dacd35de58995d3420fba7b3d6b29562311d2eef945cc04b08ffaac1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
