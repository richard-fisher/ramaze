##
# The code in this file adds an extra option and a route to Ramaze that allows REST like
# HTTP requests. For example, when this file is loaded a GET request to a controller will
# be mapped to the "show" method while a POST request will be mapped to "create". In order
# to use this extension you have to load it manually:
#
#  require 'ramaze/rest'
#
# From this point on you can customize the route as following:
#
#  Ramaze.options.rest_rewrite['GET'] = 'another_method'
#
module Ramaze
  # Don't use one option per method, we don't want to turn request_method into a symbol, 
  # together with MethodOverride this could lead to a memory leak.
  options.o(
    'REST rewrite mapping', 
    :rest_rewrite, 
    {
      'GET'    => 'show',
      'POST'   => 'create',
      'PUT'    => 'update',
      'DELETE' => 'destroy'
    }
  )

  # Re-write the URLs according to the settings set above
  Rewrite['REST dispatch'] = lambda do |path, request|
    if suffix = Ramaze.options[:rest_rewrite][request.request_method]
      "#{path}/#{suffix}".squeeze('/')
    else
      path
    end
  end
end # Ramaze
