desc 'Updates the .gem file based on the Gemspec/Gemfile'
task :gems do
  require 'bundler'
  require 'shellwords'

  handle = File.open(File.expand_path('../../.gems', __FILE__), 'w')

  Bundler.load

  Bundler.definition.dependencies.each do |dep|
    handle.puts dep.name
  end

  handle.close
end
