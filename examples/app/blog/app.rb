# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'
require 'sequel'
require 'sqlite3'
require 'bcrypt'
require 'rdiscount'

# Make sure that Ramaze knows where you are. Without this layouts and such
# wouldn't be rendered. While Ramaze.options.roots includes "." (the current
# directory) you should not rely on this path as it changes depending from what
# directory this script was called.
Ramaze.options.roots = [__DIR__]

# Initialize controllers and models
require __DIR__('model/init')
require __DIR__('controller/init')

Ramaze::Log.info('Logging in can be done by going to /users/login')
