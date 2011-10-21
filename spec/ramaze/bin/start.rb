require File.expand_path('../../../../spec/helper', __FILE__)
require __DIR__('../../../lib/ramaze/bin/runner')
require 'open3'

describe('Ramaze::Bin::Start') do

  it('Should show a help message') do
    help = `#{Ramaze::BINPATH} start -h`.strip

    help.include?(Ramaze::Bin::Start::Banner).should === true
  end

  it('Start using a directory') do
    output = ''

    Open3.popen3(Ramaze::BINPATH, 'start', Ramaze::BIN_APP) do |sin, sout, serr|
      output += serr.gets(80).to_s.strip

      serr.close
    end

    output.should.match /INFO\s+WEBrick/
  end

  it('Start using a file') do
    output = ''
    path   = File.join(Ramaze::BIN_APP, 'config.ru')

    Open3.popen3(Ramaze::BINPATH, 'start', path) do |sin, sout, serr|
      output += serr.gets(80).to_s.strip

      serr.close
    end

    output.should.match /INFO\s+WEBrick/
  end

end
