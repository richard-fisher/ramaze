require File.expand_path('../../../../spec/helper', __FILE__)
require __DIR__('../../../lib/ramaze/bin/runner')

describe('Ramaze::Bin::Runner') do

  it('Executable should exist and should be readable') do
    File.exist?(Ramaze::BINPATH).should    === true
    File.readable?(Ramaze::BINPATH).should === true
  end

  it('Should show a help message') do
    help, help_1 = `#{Ramaze::BINPATH}`.strip, `#{Ramaze::BINPATH} -h`.strip

    help.should                                       === help_1
    help.include?(Ramaze::Bin::Runner::Banner).should === true
    help.include?('Options').should                   === true
    help.include?('Commands').should                  === true

    # Check if all the commands are displayed
    Ramaze::Bin::Runner::Commands.each do |name, klass|
      help.include?(name.to_s).should === true
    end
  end

  it('Should show the version number') do
    `#{Ramaze::BINPATH} -v`.strip.should        === Ramaze::VERSION
    `#{Ramaze::BINPATH} --version`.strip.should === Ramaze::VERSION
  end

end
