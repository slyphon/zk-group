require 'rubygems'
require 'bundler/setup'

Bundler.require(:development, :test)

require 'zk-group'
require 'benchmark'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../{support,shared}/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  config.include(WaitWatchers)
  config.extend(WaitWatchers)

  config.include(SpecGlobalLogger)
  config.extend(SpecGlobalLogger)
end

class ::Thread
  # join with thread until given block is true, the thread joins successfully, 
  # or timeout seconds have passed
  #
  def join_until(timeout=2)
    time_to_stop = Time.now + timeout

    until yield
      break if Time.now > time_to_stop
      break if join(0)
      Thread.pass
    end
  end
  
  def join_while(timeout=2)
    time_to_stop = Time.now + timeout

    while yield
      break if Time.now > time_to_stop
      break if join(0)
      Thread.pass
    end
  end
end


