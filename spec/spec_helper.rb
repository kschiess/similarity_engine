require 'spec'
require 'flexmock'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'active_record'
require 'active_support'

# ActiveRecord Logger - So SQL debugging gets easier
logdir = File.join(File.dirname(__FILE__), '../log')
FileUtils.mkdir_p(logdir)

ActiveRecord::Base.logger = Logger.new(File.join(logdir, 'test.log'))
ActiveRecord::Base.logger.info "Test run started at #{Time.now.to_s}"

# Set up database connection
ActiveRecord::Base.establish_connection(
  :database => 'test', 
  :username => nil, 
  :password => nil, 
  :host => '127.0.0.1', 
  :adapter => 'mysql'
)

# Set up mocking
Spec::Runner.configure do |config|
  # Set up a transaction around each specification. This also prevents specifications to use transactions themselves.
  # This is almost but not quite like rails transactional fixtures
  config.before(:each) do 
    ActiveRecord::Base.send :increment_open_transactions
    ActiveRecord::Base.connection.execute('BEGIN')
  end
  config.after(:each) do
    ActiveRecord::Base.connection.execute('ROLLBACK')
    ActiveRecord::Base.send :decrement_open_transactions
  end
  config.mock_with :flexmock
end

# Turn off output from migration into test database.
ActiveRecord::Migration.verbose = false

# Install table structure needed for Index
require 'fixtures/similarity_coefficient_schema'

# Load the init from the plugin - this will change sometimes and we don't 
# want a copy here. 
require File.join(File.dirname(__FILE__), '../init')