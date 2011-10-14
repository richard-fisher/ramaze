# Testing With Ramaze

Ramaze uses and encourages BDD (Behaviour Driven Development). It comes out of
the box with a helper for [Bacon][bacon]. Bacon is a small [Rspec][rspec] clone
used by Ramaze for all specifications (also known as "specs").

Writing tests with Bacon results to clean and complete specifications with
minimum learning time and effort for adaptation. When creating a new Ramaze
application using ``ramaze create`` Ramaze will automatically generate a
directory for your specifications.

Ramaze does not enforce the use of a particular testing library but for the sake
of simplicity this guide assumes you'll be using Bacon. In order to use Bacon
you must first install it from Rubygems. This can be done using the following
command:

    gem install bacon

In order to run the tests in the spec directory you can run the following
command:

    bacon spec/*

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
If you have Python installed you can start a webserver directly on port 11111
and browse to the same folder. This can be done as following:

    python -m SimpleHTTPServer 11111

For more information on using Simplecov see the [Github project][simplecov gh].

[bacon]: https://github.com/chneukirchen/bacon
[simplecov]: https://github.com/colszowka/simplecov
[rspec]: http://relishapp.com/rspec
[simplecov gh]: https://github.com/colszowka/simplecov
