require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/test_case'
require 'shoulda'
require 'shoulda/rails'
require 'factory_girl'
require 'authlogic'
require 'authlogic/test_case'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'shoulda_macros'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'master_may_i'

BASE = File.dirname(__FILE__)

# Configure Factory Girl
require BASE + "/factories.rb"

# Configure the logger
ActiveRecord::Base.logger = Logger.new(BASE + "/debug.log")
RAILS_DEFAULT_LOGGER = ActiveRecord::Base.logger

# Establish the database connection
config = YAML::load_file(BASE + '/database.yml')
ActiveRecord::Base.establish_connection(config['sqlite3'])

# Load the database schema
load(BASE + "/schema.rb")

# class Test::Unit::TestCase
# end

