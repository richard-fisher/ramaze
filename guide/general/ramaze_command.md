# @title Ramaze Command
# Ramaze Command

Ramaze ships with a relatively simple command, named "ramaze". This command can
be used to create new applications as well as starting them. To make reading
this guide easier we'll call this command "bin/ramaze" from now on.

<div class="note deprecated">
    <p>
        <strong>Warning</strong>: bin/ramaze is not a scaffolding application.
        It can merely be used for some basic application management and creating
        a basic Ramaze application.
    </p>
</div>

## Creating Applications

As mentioned earlier bin/ramaze can be used to create new applications. In order
to create a new application in the current directory all you have to do is
executing the following command:

    $ ramaze create APPNAME

APPNAME is the name of your new application and will also be used as the
directory name. If the application was named "blog" there would now be a
directory called "blog" in the current one. This directory will contain all
basic files that can be used for a Ramaze powered application.

## Application Prototypes

Due to Ramaze's nature it's very easy to create your own application prototype
if you dislike the default one. For example, I've made some small modifications
to the default prototype so that it looks like the followng:

    .__ app.rb
    |__ config
    |   |__ config.rb
    |   |__ database.rb
    |   |__ middlewares.rb
    |   |__ requires.rb
    |
    |__ config.ru
    |__ controller
    |__ layout
    |   |__ default.xhtml
    |
    |__ log
    |__ public
    |__ spec
    |__ start.rb
    |__ view

This prototype is basically a minimal version of the default one but with a
special directory for all configuration files. In order to use this prototype I
had to make some small changes to app.rb, the look like the following:

    require 'ramaze'

    # Load the file that in turn will load all gems, keeps this file clean
    require __DIR__('config/requires')

    # Configure our application
    require __DIR__('config/config')

    # Load our database settings
    require __DIR__('config/database')

    # Load all Rack middlewares
    require __DIR__('config/middlewares')

    # Load all controllers
    Dir.glob(__DIR__('controller') + '/**/*.rb').each do |f|
      require f
    end

This is only a basic example of the flexibility of Ramaze, I highly recommend
you playing around with your own prototypes as it's a great way to learn the
basics of Ramaze and to really understand how flexible Ramaze is.

<div class="note todo">
    <p>
        <strong>Note</strong>: This prototype does not come with Ramaze, it's
        just an example of what you could make yourself.
    </p>
</div>

## Running Applications

When you've created an application there are three ways of running it. You can
either use your server's command such as `thin` or `unicorn` but you can also
use a supplied Rake task:

    $ rake ramaze:start

If you want to stop the running application you can simply close it by using
the key combination Ctrl+C.

<div class="note todo">
    <p>
        <strong>Note</strong>: There are many different ways to start your
        application depending on the server you're using. Fore more information
        it's best to look at the documentation of your favorite webserver.
    </p>
</div>

## Ramaze Console

By default Ramaze allows you to start a console using either IRB or Pry. These
consoles can be started by running `rake ramaze:irb` and `rake ramaze:pry`
respectively.
