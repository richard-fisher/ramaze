require File.expand_path('../../../../spec/helper', __FILE__)
require __DIR__('../../../lib/ramaze/bin/runner')

module Ramaze
  BINPATH = __DIR__('../../../bin/ramaze')
  PROTO   = __DIR__('../../../lib/proto')
end

describe('Ramaze::Bin::Start') do

  it('Should show a help message') do
    help = `#{Ramaze::BINPATH} start -h`.strip

    help.include?(Ramaze::Bin::Start::Banner).should === true
  end

  it('Start using a directory') do
    pid = File.join(Ramaze::PROTO, 'proto.pid')
    cmd = Ramaze::Bin::Start.new
    cmd.run([Ramaze::PROTO, "-P #{pid}", '-D'])

    # Confirm that the process is running
    should.not.raise(Errno::ESRCH) do
      Process.getpriority(Process::PRIO_PROCESS, File.read(pid).to_i)
    end

    sleep(2)
    Process.kill(9, File.read(pid).to_i)
  end

end
