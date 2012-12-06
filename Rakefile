require 'rubygems'
require 'rake'
require 'date'
require 'time'
require 'rubygems/package_task'

PROJECT_SPECS = Dir.glob(File.expand_path('../spec/ramaze/**/*.rb', __FILE__))

GEMSPEC = Gem::Specification::load(
  File.expand_path('../ramaze.gemspec', __FILE__)
)

Gem::PackageTask.new(GEMSPEC) do |pkg|
  pkg.need_tar = false
  pkg.need_zip = false
end

Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each do |task|
  import task
end

task :default => :bacon
