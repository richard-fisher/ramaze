require File.expand_path('../../../../spec/helper', __FILE__)

spec_precondition 'ruby-growl is installed' do
  if !RUBY_PLATFORM.include?('darwin')
    should.flunk 'Growl can only be installed on Mac OS'
  else
    spec_require 'ruby-growl'
  end
end

spec_precondition 'Growl should be running' do
  begin
    growl = Ramaze::Logger::Growl.new
    growl.log(:info, 'Ramaze connection test')
  rescue
    should.flunk 'Growl is not running'
  end
end

require 'ramaze/log/growl'

# Configure Growl, make sure your growl server matches
# these settings.
Ramaze::Logger::Growl.trait[:defaults][:name]     = 'ramaze'
Ramaze::Logger::Growl.trait[:defaults][:password] = 'ramaze'

describe Ramaze::Logger::Growl do
  it 'Create a new instance of the Growl logger' do
    growl = Ramaze::Logger::Growl.new

    growl.should.respond_to? :log
  end

  it 'Send a growl notification' do
    growl = Ramaze::Logger::Growl.new
    growl.log(:info, 'Hello, Ramaze!')

    # The Growl library doesn't seem to return anything,
    # let's ask the user if the notification was sent
    print "Did you see the the notification? (y/n) "
    response = gets.strip

    response.should.satisfy do |object|
      object === 'y' or object === 'yes'
    end
  end
end
