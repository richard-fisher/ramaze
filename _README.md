    Copyright (c) 2009 - 2011 Michael Fellinger m.fellinger@gmail.com
    All files in this distribution are subject to the terms of the Ruby license.

# About Ramaze

Ramaze is a very simple and straight-forward web-framework.
The philosophy of it could be expressed in a mix of KISS and POLS, trying to
make simple things simple and complex things possible.

This of course is nothing new to anyone who knows some ruby, but is often
forgotten in a chase for new functionality and features. Ramaze only tries to
give you the ultimate tools, but you have to use them yourself to achieve
perfect custom-tailored results.

Another one of the goals during development of Ramaze was to make every part as
modular and therefor reusable as possible, not only to provide a basic
understanding after the first glance, but also to make it as simple as possible
to reuse parts of the code.

The original purpose of Ramaze was to act as a kind of framework to build
web-frameworks, this was made obsolete by the introduction of rack, which
provides this feature at a better level without trying to enforce any structural
layout of the resulting framework.

## Quick Example

While Ramaze applications are usually spread across multiple directories for controllers,
models and views one can quite easily create a very basic application in just a single file:

    require 'ramaze'

    class MyController < Ramaze::Controller
      map '/'

      def index
        "Hello, Ramaze!"
      end
    end

    Ramaze.start

Once this is saved in a file (you can also run this from IRB) simply execute it using the
Ruby binary:

    $ ruby hello_ramaze.rb

This starts a WEBRick server listening on localhost:7000.

## Features Overview

Ramaze offers following features at the moment:

### Adapters

Ramaze takes advantage of the Rack library to provide a common way of
handling different ways to serve its content. A few of the supported Rack adapters are:

* Mongrel
* WEBrick
* FCGI
* LiteSpeed
* Thin

### Templates

Ramaze can in theory support any template engine as long as there's an adapter for it. To
make your life easier Ramaze ships with adapters for the following template engines:

* [Erubis](http://rubyforge.org/projects/erubis)
* Etanni (small engine created for Ramaze)
* [Erector](http://erector.rubyforge.org/)
* [Haml](http://haml.hamptoncatlin.com/)
* [Liquid](http://home.leetsoft.com/liquid)
* [Markaby](http://code.whytheluckystiff.net/markaby/)
* [Remarkably](http://rubyforge.org/projects/remarkably)
* [Sass](http://haml.hamptoncatlin.com/docs/sass)

### Cache

* Hash
* YAML::Store
* LocalMemCache
* MemCache
* Sequel

### Helpers

Helpers are modules that can be included in your controllers or other classes to make it easier
to work with certain classes or systems without having to write the same boilerplate code over
and over again. Ramaze has a lot of helpers, the following helpers are loaded by default:

* CGI: Shortcuts for escape/unescape of the CGI module.
* File: Helps you serving files from your Controller.
* Flash: Store a couple of values for one request associated with a session.
* Link: Easier linking to the various parts of your applications Controllers and Actions.
* Redirect: Easy redirection.

Other helpers worth mentioning are:

* CSRF helper: protect your forms from CSRF attacks using a single method.
* BlueForm: makes working with forms fun again.
* User: easy authentication using a database model.
* Identity: makes it easy to work with OpenID systems.

In total Ramaze itself has 29 helpers!

## Basic Principles


