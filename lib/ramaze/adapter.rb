#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity'
require 'ramaze/tool/record'
require 'ramaze/adapter/base'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze

  # Shortcut to the HTTP_STATUS_CODES of Rack::Utils
  # inverted for easier access

  STATUS_CODE = Rack::Utils::HTTP_STATUS_CODES.invert

  # This module holds all classes and methods related to the adapters like
  # webrick or mongrel.
  # It's responsible for starting and stopping them.

  module Adapter
    class << self

      # Is called by Ramaze.startup and will first call start_adapter and wait
      # up to 3 seconds for an adapter to appear.
      # It will then wait for the adapters to finish If Global.run_loose is
      # set or otherwise pass you on control which is useful for testing or IRB
      # sessions.

      def startup options = {}
        start_adapter

        Timeout.timeout(3) do
          sleep 0.01 until Global.adapters.any?
        end

        Global.adapters.each{|a| a.join} unless Global.run_loose

      rescue SystemExit
        Ramaze.shutdown
      rescue Object => ex
        Log.error(ex)
        Ramaze.shutdown
      end

      # Takes Global.adapter and starts if test_connections is positive that
      # connections can be made to the specified host and ports.
      # If you set Global.adapter to false it won't start any but deploy a
      # dummy which is useful for testing purposes where you just send fake
      # requests to Dispatcher.

      def start_adapter
        if adapter = Global.adapter
          host, ports = Global.host, Global.ports

          if Global.test_connections
            Log.info("Adapter: #{adapter}, testing connection to #{host}:#{ports}")
            test_connections(host, ports)
            Log.info("and we're running: #{host}:#{ports}")
          end

          adapter.start(host, ports)
        else # run dummy
          Global.adapters.add Thread.new{ sleep }
          Log.warn("Seems like Global.adapter is turned off", "Continue without adapter.")
        end
      rescue LoadError => ex
        Log.warn(ex, "Continue without adapter.")
      end

      # Calls ::shutdown on all running adapters and waits up to 1 second for
      # them to finish, then goes on to kill them and exit still.

      def shutdown
        Timeout.timeout(1) do
          Global.adapters.each do |adapter|
            a = adapter[:adapter]
            a.shutdown if a.respond_to?(:shutdown)
          end
        end
      rescue Timeout::Error
        Global.adapters.each{|a| a.kill! }
        # Hard exit! because it won't be able to kill Webrick otherwise
        exit!
      end

      # check the given host and ports via test_connection.
      # Shuts down if no connection is possible.

      def test_connections host, ports
        ports.each do |port|
          unless test_connection(host, port)
            Log.error("Cannot open connection on #{host}:#{port}")
            Ramaze.shutdown
          end
        end
      end

      # Opens a TCPServer temporarily and returns true if a connection is
      # possible and false if none can be made

      def test_connection host, port
        Timeout.timeout(1) do
          testsock = TCPServer.new(host, port)
          testsock.close
          true
        end
      rescue => ex
        Log.error(ex)
        false
      end
    end
  end
end
