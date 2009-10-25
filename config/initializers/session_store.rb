# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_agnostic_blog_session',
  :secret      => '3865af3217b90d3e51419fc4a910ba35cb1a48c811f8bc8a9206b369668215b0f6535ca2f53f4a93f6bd48eeeeb6125697bdb7b5c427024caffd4fae18cd3cf7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
