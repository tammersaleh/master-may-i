# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_rails3_root_session',
  :secret => '41609545fea4b7994d7a35db9b01917e313a6c24ad682dd7aed00917b9a7eb5e0a1e3a764c7a2b0c2af762bfe60ef7fdbfbd42e540c77039a66975a03be1a2e6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
