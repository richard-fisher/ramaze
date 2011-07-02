#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
require "ramaze/tool/bin"

require "pathname"

module Ramaze
  BINPATH = Pathname(Ramaze::ROOT).join("../bin/ramaze").expand_path
end

USAGE = <<TXT

  Usage:
	ramaze <start [PIDFILE]|stop [PIDFILE]|restart [PIDFILE]|status [PIDFILE]|create PROJECT|console> [ruby/rack options]

	Commands:

	  * All commands which take an optional PIDFILE (defaults to PROJECT.pid otherwise).
	  * All commands which start a ramaze instance will default to webrick on port 7000
	    unless you supply the rack options -p/--port PORT and/or * -s/--server SERVER.

	 start   - Starts an instance of this application.

	 stop    - Stops a running instance of this application.

	 restart - Stops running instance of this application, then starts it back up.  Pidfile
	           (if supplied) is used for both stop and start.

	 status  - Gives status of a running ramaze instance

	 create  - Creates a new prototype Ramaze application in a directory named PROJECT in
	           the current directory.  ramaze create foo would make ./foo containing an
	           application prototype. Rack options are ignored here.

	 console - Starts an irb console with app.rb (and irb completion) loaded. This command
	           ignores rack options, ARGV is passed on to IRB.

TXT

USAGE_2 = <<TXT
	Common options:
	  -h, -?, --help           Show this message
	      --version            Show version
TXT

describe "bin/ramaze command" do
  it "Can find the ramaze binary" do
    Ramaze::BINPATH.file?.should == true
  end

  it "Shows command line help" do
    output = `#{Ramaze::BINPATH} -h`
    output.should.match /#{USAGE}/
    output.should.include?(USAGE_2)
  end

  it "Shows the correct version" do
    output = %x{#{Ramaze::BINPATH} --version}
    output.strip.should == Ramaze::VERSION
  end

  it "Can create a new tree from prototype" do
    require "fileutils"
    root = Pathname.new("/tmp/test_tree")
    raise "#{root} already exists, please move it out of the way before running this test" if root.directory?
    begin
      output = %x{#{Ramaze::BINPATH} create #{root}}
      root.directory?.should.be.true
      root.join("config.ru").file?.should.be.true
      root.join("start.rb").file?.should.be.true
      root.join("controller").directory?.should.be.true
      root.join("controller", "init.rb").file?.should.be.true
      root.join("view").directory?.should.be.true
      root.join("model").directory?.should.be.true
      root.join("model", "init.rb").file?.should.be.true
    ensure
      FileUtils.rm_rf(root)
    end
  end

end

