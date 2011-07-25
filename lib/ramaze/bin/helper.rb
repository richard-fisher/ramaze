module Ramaze
  #:nodoc:
  module Bin
    ##
    # Module containing various helper methods useful for most commands.
    #
    # @author Yorick Peterse
    # @author TJ Vanderpoel
    # @since  21-07-2011
    #
    module Helper
      ##
      # Checks if the specified PID points to a process that's already running.
      #
      # @author TJ Vanderpoel
      # @since  21-07-2011
      # @param  [String] pid The path to the PID.
      # @return [TrueClass|FalseClass]
      #
      def is_running?(pid)
        return false if !File.exist?(pid)

        pid = File.read(pid).to_i

        if is_windows?
          wmi             = WIN32OLE.connect("winmgmts://")
          processes, ours = wmi.ExecQuery(
            "select * from win32_process where ProcessId = #{pid}"
          ), []

          processes.each { |process| ours << process.Name }

          return ours.first.nil?
        else
          begin
            prio = Process.getpriority(Process::PRIO_PROCESS, pid)
            return true
          rescue Errno::ESRCH
            return false
          end
        end
      end

      ##
      # Checks if the system the user is using is Windows.
      #
      # @author TJ Vanderpoel
      # @since  21-07-2011
      # @return [TrueClass|FalseClass]
      #
      def is_windows?
        return @is_win if @is_win

        begin; require "win32ole"; rescue LoadError; end

        @is_win ||= Object.const_defined?("WIN32OLE")
      end

      ##
      # Tries to extract the path to the Rackup executable.
      #
      # @author TJ Vanderpoel
      # @since  21-07-2001
      # @return [String]
      #
      def rackup_path
        return @rackup_path if @rackup_path

        # Check with 'which' on platforms which support it
        unless is_windows?
          @rackup_path = %x{which rackup}.to_s.chomp

          if @rackup_path.size > 0 and File.file?(@rackup_path)
            return @rackup_path
          end
        end

        # check for rackup in RUBYLIB
        libs = ENV["RUBYLIB"].to_s.split(is_windows? ? ";" : ":")

        if rack_lib = libs.detect { |r| r.match %r<(\\|/)rack\1> }
          require "pathname"
          @rackup_path = Pathname.new(rack_lib).parent.join("bin").join(
            "rackup"
          ).expand_path
          
          return @rackup_path if File.file?(@rackup_path)
        end

        begin
          require "rubygems"
          require "rack"
          require "pathname"

          @rackup_path = Pathname.new(Gem.bindir).join("rackup").to_s

          return @rackup_path if File.file?(@rackup_path)
        rescue LoadError
          nil
        end

        @rackup_path = nil
        abort "Cannot find the path to the Rackup executable"
      end
    end # Helper
  end # Bin
end # Ramaze
