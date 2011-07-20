begin; require 'rubygems'; rescue LoadError; end
require 'rake'
require 'date'
require 'time'

# All the bacon specifications
PROJECT_SPECS = Dir.glob(File.expand_path('../spec/ramaze/**/*.rb', __FILE__))

# Load the gemspec so it's details can be used in all the Rake tasks
GEMSPEC = Gem::Specification::load(
  File.expand_path('../ramaze.gemspec', __FILE__)
)

Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each do |f|
  import(f)
end

# Set the default task to running all the bacon specifications
task :default => [:bacon]
