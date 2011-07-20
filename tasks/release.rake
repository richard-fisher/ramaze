namespace :release do
  task :prepare => %w[authors gemspec]
  task :all     => %w[release:rubygems]

  desc 'Release on rubygems'
  task :rubygems => ['release:prepare', :package] do
    name, version = GEMSPEC.name, GEMSPEC.version

    puts <<-INSTRUCTIONS
================================================================================

To publish to Rubygems do following:

gem push pkg/#{name}-#{version}.gem

================================================================================
    INSTRUCTIONS
  end
end
