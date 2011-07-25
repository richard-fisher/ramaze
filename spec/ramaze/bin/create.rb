require File.expand_path('../../../../spec/helper', __FILE__)
require __DIR__('../../../lib/ramaze/bin/runner')
require 'fileutils'

describe('Ramaze::Bin::Create') do

  it('Show a help message') do
    help = `#{Ramaze::BINPATH} create -h`.strip

    help.include?(Ramaze::Bin::Create::Banner).should === true
  end

  it('Warn when no name is given') do
    output = `#{Ramaze::BINPATH} create 2>&1`.strip

    output.should === 'You need to specify a name for your application'
  end

  it('Create a new application') do
    output = `#{Ramaze::BINPATH} create /tmp/ramaze`.strip

    File.directory?('/tmp/ramaze').should    === true
    File.exist?('/tmp/ramaze/app.rb').should === true

    FileUtils.rm_rf('/tmp/ramaze')
  end

end
