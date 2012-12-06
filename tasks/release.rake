namespace :release do
  desc 'Prepares a release'
  task :prepare => [:authors, :changelog, :gems] do
    puts <<-INSTRUCTIONS
Prepared version #{GEMSPEC.version} set to be released
on #{GEMSPEC.date.strftime('%Y-%m-%d')}. Once you have committed the changed
files (if any) you can release a new Gem as following:

    $ rake release:push

    INSTRUCTIONS
  end

  desc 'Tags a new release'
  task :tag do
    sh("git tag -a -m 'Release #{GEMSPEC.version}' -s #{GEMSPEC.version}")
    sh("git push origin : #{GEMSPEC.version}")
  end

  desc 'Pushes a new release to Rubygems'
  task :push => :tag do
    name = "#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
    gem  = File.expand_path("../../pkg/#{name}", __FILE__)

    puts "About to push #{GEMSPEC.name} version #{GEMSPEC.version}"
    print 'Are you really sure you want to continue? y/n: '

    confirmed = STDIN.gets

    if !confirmed or confirmed != 'y'
      abort 'Aborting'
    end

    unless File.file?(gem)
      abort "The gem #{name} does not exist, you can build it using `rake gem`"
    end

    sh("gem push #{gem}")
  end
end
