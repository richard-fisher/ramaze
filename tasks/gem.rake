namespace :gem do
  desc 'builds the gem and moves it to the pkg/ directory'
  task :build do
    sh "gem build #{GEMSPEC.name}.gemspec"
    sh "mv #{GEMSPEC.name}-#{GEMSPEC.version}.gem pkg/"
  end

  desc "package and install from gemspec"
  task :install do
    sh "gem install pkg/#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
  end

  desc "uninstall the gem"
  task :uninstall do
    sh %{gem uninstall -x #{GEMSPEC.name}}
  end
end # namespace :gem
