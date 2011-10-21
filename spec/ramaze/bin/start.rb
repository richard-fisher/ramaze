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

    Open3.popen2e(Ramaze::BINPATH, 'start', Ramaze::BIN_APP) do |sin, sout|
      got = sout.gets(80)

      if !got.nil?
        output += got.to_s.strip
      end

      sout.close
    end

    output.should.match /INFO\s+WEBrick/
  end

  it('Start using a file') do
    output = ''
    path   = File.join(Ramaze::BIN_APP, 'config.ru')

    Open3.popen2e(Ramaze::BINPATH, 'start', path) do |sin, sout|
      got = sout.gets(80)

      if !got.nil?
        output += got.to_s.strip
      end

      sout.close
    end

    output.should.match /INFO\s+WEBrick/
  end
end
