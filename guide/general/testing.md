# Testing Ramaze

Ramaze uses and encourages BDD (Behaviour Driven Development). Ramaze itself is
tested using [Bacon][bacon] and supports it out of the box, it however isn't
limited to just Bacon.

One might wonder why to bother with writing tests. The answer to this is quite
simple: stability. Manually testing an application works on a very basic level
but there are various issues that will arise once your application grows. The
two biggest issues are human errors and repeatability. Especially the latter
becomes an issue when your development team grows in size, while the initial
developer may be willing to manually test every feature every time a change has
been made others might not. Even worse, there's a chance they won't test their
code at all and assume it's production ready because on their setup.

Writing tests that can be executed using a single command (or automatically)
makes your life a lot easier as you no longer have to worry about any of these
issues (assuming people actually write tests). Whenever somebody commits code
they write a test and you can easily verify if it works on different setups by
simply running said test.

When writing Ruby code you can pick from a large collection of testing libraries
such as Bacon and [Rspec][rspec] for general tests, [SimpleCov][simplecov] for
code coverage and [Capybara][capybara] for testing form based actions and the
like. Of course the list doesn't stop here, there's simply too much to discuss
everything.

## Bacon

Bacon is a small and lightweight Rspec clone that's used by Ramaze and Innate
and is the recommended tool to use. Each bacon test consists out of at least two
bits: a "describe" block and an "it" (or "should") block. The describe block can
be seen as a group of multiple it/should blocks. In most cases these blocks are
used to specify the name of a class, module, etc. The it/should blocks are used
for individual tests.

Lets take a look at a simple block of code:

    class Person
      attr_accessor :name

      def initialize(name = nil)
        @name = name
      end
    end

Using Bacon we can test this code as following:

    require 'bacon'

    describe 'Person' do
      should 'respond to #name' do
        person = Person.new

        person.respond_to?(:name).should  == true
        person.respond_to?(:name=).should == true
      end

      should 'set the name in the constructor' do
        person = Person.new('Matz')

        person.name.should == 'Matz'
      end

      should 'set the name using #name=' do
        person = Person.new

        person.name = 'Matz'

        person.name.should == 'Matz'
      end
    end

For more information on the syntax of Bacon and other information see the
[Bacon Github project][bacon].

### Bacon With Ramaze

Ramaze makes it easy to test your code using Bacon by providing you with a small
helper file. This file can be loaded as following:

    require 'ramaze/spec/bacon'

This file adds two bacon contexts (rack_test and webrat), configures Ramaze to
only show error messages and adds a few helper methods.

### Bacon and Rack::Test

In order to test Ramaze specific code you'll need to use a tool that's capable
of mocking Rack requests or execute this request in a different way (e.g. using
Selenium). Rack::Test (gem install rack-test) makes it possible to test your
Rack based (and thus Ramaze) applications without having to use a webbrowser.

Ramaze makes it easy to use Rack::Test by defining a special bacon context:
"rack_test". This context can be used by calling `behaves_like :rack_test`
inside your describe block:

    describe 'Using Rack::Test' do
      behaves_like :rack_test
    end

Once loaded you can execute HTTP requests using methods such as `get`:

    describe 'Using Rack::Test' do
      behaves_like :rack_test

      should 'display the homepage' do
        get('/').body.should == 'Hello, Rack::Test!'
      end
    end

More information about Rack::Test can be found on the [Github page of
Rack::Test][rack-test].

## Capybara

Capybara is a Gem that can be used to simulate browser requests using
Rack::Test, Selenium or other drivers, it's even capable of testing Javascript
based code using Selenium.

In order to use Capybara you must first install it:

    $ gem install capybara

Once installed you'll have to configure Capybara so it knows how to use your
Ramaze application. Depending on the testing Gem you're using you'll also have
to configure said Gem, for this guide it's assumed that you're using Bacon.

First you should load and configure Capybara:

    require 'capybara'
    require 'capybara/dsl'
    require 'bacon'

    # Tells Capybara which driver to use and where to find your application.
    # Without this Capybara will not work properly.
    Capybara.configure do |config|
      config.default_driver = :rack_test
      config.app            = Ramaze.middleware
    end

Next you'll have to set up a context for Bacon:

    shared :capybara do
      Ramaze.setup_dependencies
      extend Capybara::DSL
    end

Last but not least, make sure Ramaze knows about your root directories and set
your mode:

    Ramaze.options.roots << 'path/to/spec/directory'
    Ramaze.options.mode  = :spec

Once all of this has been done you can start using Capybara. A simple example of
this is the following:

    class MainController < Ramaze::Controller
      map '/'

      def index
        return 'Hello, Ramaze!'
      end

      def redirect_request
        redirect(MainController.r(:index))
      end
    end

    describe 'Testing Ramaze' do
      behaves_like :capybara

      it 'Go to the homepage' do
        visit '/'

        page.has_content?('Hello, Ramaze!').should == true
      end

      it 'Follow redirects' do
        visit '/redirect_request'

        page.current_path.should == '/index'
        page.has_content?('Hello, Ramaze!').should == true
      end
    end

For more information on how to use Capybara with other testing tools, how to use
the syntax and so on you should resort to the [Capybara Github page][capybara].

## Code Coverage using SimpleCov

To test the Ramaze application tests coverage, you can use a tool like
[SimpleCov][simplecov]. SimpleCov requires minimal effort to get integrated,
start by installing the gem:

    gem install simplecov

In order to actually measure your code coverage you'll have to tell SimpleCov a
bit about your application. This is done by loading Simplecov and starting it
*before* loading all your tests. This can be done by using the following code:

    require 'simplecov'

    SimpleCov.start

    # Load the existing files
    Dir.glob('spec/*.rb').each do |spec_file|
      unless File.basename(spec_file) == 'init.rb'
        require File.expand_path(spec_file)
      end
    end

In order to run the file you'd simply invoke the following:

    bacon spec/init.rb

Upon success SimpleCov will create a new directory ``coverage`` with the
results. You can point your browser to the index.html file inside that directory
to view the results.

For more information on using Simplecov see the [Github project][simplecov].

[bacon]: https://github.com/chneukirchen/bacon
[simplecov]: https://github.com/colszowka/simplecov
[rspec]: http://relishapp.com/rspec
[capybara]: http://jnicklas.github.com/capybara/
[rack-test]: https://github.com/brynary/rack-test
