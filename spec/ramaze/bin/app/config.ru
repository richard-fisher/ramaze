require File.expand_path('../../../../../lib/ramaze', __FILE__)

class MainController < Ramaze::Controller
  map '/'

  def index; end
end

Ramaze.start(:root => __DIR__, :started => true)

run Ramaze
