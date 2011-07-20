require 'less'

module Ramaze
  module View
    ##
    # Adapter that allows you to use Less in your views for stylesheets. See the
    # Less website for more information: http://lesscss.org/
    #
    module Less
      def self.call(action, string)
        less = View.compile(string){|s| ::Less::Engine.new(s) }
        return less.to_css, 'text/css'
      end
    end # Less
  end # View
end # Ramaze
