module Ramaze
  # Array containing the names and versions of all the gems required by Ramaze
  # along with the name of how the gem should be required.
  DEPENDENCIES = [
    {:name => 'innate', :version => ['>= 2010.03']}
  ]

  # Array containing all the development dependencies.
  DEVELOPMENT_DEPENDENCIES = [
    {:name => 'abstract'    , :version => ['>= 1.0.0']},
    {:name => 'addressable' , :version => ['>= 2.1.1'], :setup => false},
    {:name => 'bacon'       , :version => ['>= 1.1.0']},
    {:name => 'builder'     , :version => ['>= 2.1.2']},
    {:name => 'dalli'       , :version => ['>= 1.0.5']},
    {:name => 'erector'     , :version => ['>= 0.8.2']},
    {:name => 'erubis'      , :version => ['>= 2.6.5']},
    {:name => 'ezamar'      , :version => ['>= 2009.06']},
    {:name => 'haml'        , :version => ['>= 2.2.22']},
    {:name => 'hpricot'     , :version => ['>= 0.8.2']},
    {:name => 'json'        , :version => ['>= 1.2.3']},
    {:name => 'less'        , :version => ['>= 1.2.21']},
    {:name => 'liquid'      , :version => ['>= 2.0.0']},
    {:name => 'locale'      , :version => ['>= 2.0.5']},
    {:name => 'lokar'       , :version => ['>= 0.1.0']},
    {:name => 'maruku'      , :version => ['>= 0.6.0']},
    {:name => 'mustache'    , :version => ['>= 0.9.2']},
    {:name => 'mutter'      , :version => ['>= 0.5.3']},
    {:name => 'nagoro'      , :version => ['>= 2009.05']},
    {:name => 'rack-contrib', :version => ['>= 0.9.2'], :lib => 'rack/contrib'},
    {:name => 'rack-test'   , :version => ['>= 0.5.3'], :lib => 'rack/test'},
    {:name => 'Remarkably'  , :version => ['>= 0.5.2'], :lib => 'remarkably'},
    {:name => 'RubyInline'  , :version => ['>= 3.8.4'], :lib => 'inline'},
    {:name => 'sequel'      , :version => ['>= 3.9.0']},
    {:name => 'slippers'    , :version => ['>= 0.0.14']},
    {:name => 'sqlite3-ruby', :version => ['>= 1.2.5'], :lib => 'sqlite3'},
    {:name => 'tagz'        , :version => ['>= 7.2.3']},
    {:name => 'tenjin'      , :version => ['>= 0.6.1']},
    {:name => 'yard'        , :version => ['>= 0.7.2']},
    {:name => 'scaffolding_extensions', :version => ['>= 1.4.0']}
  ]

  if !RUBY_PLATFORM.include?('darwin')
    DEVELOPMENT_DEPENDENCIES.push(
      {:name => 'localmemcache', :version => ['>= 0.4.4']}
    )
  end
end # Ramaze
