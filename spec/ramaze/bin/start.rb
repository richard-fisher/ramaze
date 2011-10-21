require File.expand_path('../../../../spec/helper', __FILE__)
require __DIR__('../../../lib/ramaze/bin/runner')

module Ramaze
  module Bin
    class Start
      # Stub the method so that WEBrick doesn't have to be booted up.
      def start_server(rackup_path, rackup_config, *params)
        return true
      end
    end
  end
end

describe('Ramaze::Bin::Start') do
  it('Should show a help message') do
    help = `#{Ramaze::BINPATH} start -h`.strip

    help.include?(Ramaze::Bin::Start::Banner).should === true
  end

  it('Start using a directory') do
    cmd = Ramaze::Bin::Start.new

    cmd.run([Ramaze::BIN_APP]).should == true
  end

  it('Start using a file') do
    path = File.join(Ramaze::BIN_APP, 'config.ru')
    cmd  = Ramaze::Bin::Start.new

    cmd.run([path]).should == true
  end
end
