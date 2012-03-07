module Ramaze
  # Array containing gems that aren't supported for certain reasons. The gems
  # that are in this array by default will be removed if the current setup
  # *does* support them.
  UNSUPPORTED_GEMS = [
    'lokar',
    'localmemcache',
    'ruby-growl',
    'nagoro',
    'syslog'
  ]

  # Array containing the names and versions of all the gems required by Ramaze
  # along with the name of how the gem should be required.
  DEPENDENCIES = [
    {:name => 'innate', :version => ['>= 2012.03']}
  ]

  # Array containing all the development dependencies.
  DEVELOPMENT_DEPENDENCIES = [
    {:name => 'bacon'       , :version => ['>= 1.1.0']},
    {:name => 'dalli'       , :version => ['>= 1.0.5']},
    {:name => 'erector'     , :version => ['>= 0.8.2']},
    {:name => 'erubis'      , :version => ['>= 2.7.0']},
    {:name => 'ezamar'      , :version => ['>= 2009.06']},
    {:name => 'sass'        , :version => ['>= 3.1.4']},
    {:name => 'haml'        , :version => ['>= 3.1.2']},
    {:name => 'hpricot'     , :version => ['>= 0.8.4']},
    {:name => 'liquid'      , :version => ['>= 2.2.2']},
    {:name => 'locale'      , :version => ['>= 2.0.5']},
    {:name => 'maruku'      , :version => ['>= 0.6.0']},
    {:name => 'mustache'    , :version => ['>= 0.99.4']},
    {:name => 'rack-contrib', :version => ['>= 1.1.0'], :lib => 'rack/contrib'},
    {:name => 'rack-test'   , :version => ['>= 0.6.0'], :lib => 'rack/test'},
    {:name => 'Remarkably'  , :version => ['>= 0.6.1'], :lib => 'remarkably'},
    {:name => 'sequel'      , :version => ['>= 3.25.0']},
    {:name => 'slippers'    , :version => ['>= 0.0.14']},
    {:name => 'sqlite3'     , :version => ['>= 1.3.3']},
    {:name => 'tagz'        , :version => ['>= 9.0.0']},
    {:name => 'tenjin'      , :version => ['>= 0.6.1']},
    {:name => 'yard'        , :version => ['>= 0.7.2']},
    {:name => 'redis'       , :version => ['>= 2.2.2']},
    {:name => 'rdiscount'   , :version => ['>= 1.6.8']},
    {:name => 'slim'        , :version => ['>= 1.1.0']}
  ]

  # Lokar requires Ruby >= 1.9
  if RUBY_VERSION.to_f >= 1.9
    DEVELOPMENT_DEPENDENCIES.push({:name => 'lokar', :version => ['>= 0.2.1']})
    UNSUPPORTED_GEMS.delete('lokar')
  end

  # LocalMemcache doesn't work on Mac OS X or jruby.
  if !RUBY_DESCRIPTION.include?('jruby') and !RUBY_PLATFORM.include?('darwin')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'localmemcache', :version => ['>= 0.4.4']}
    )

    UNSUPPORTED_GEMS.delete('localmemcache')
  end

  # Ruby-growl, requiring Growl, only works on Mac OS X.
  if RUBY_PLATFORM.include?('darwin')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'ruby-growl', :version => ['>= 3.0']}
    )

    UNSUPPORTED_GEMS.delete('ruby-growl')
  end

  # Nagoro doesn't seem to work on Rbx
  if !RUBY_DESCRIPTION.include?('rubinius')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'nagoro', :version => ['>= 2009.05']}
    )

    UNSUPPORTED_GEMS.delete('nagoro')
  end

  # Syslog uses forking which apparently isn't available on jruby.
  if !RUBY_DESCRIPTION.include?('jruby')
    UNSUPPORTED_GEMS.delete('syslog')
  end
end # Ramaze
