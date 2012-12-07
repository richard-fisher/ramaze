namespace :release do
  message = "Release #{GEMSPEC.version}"

  desc 'Releases a new version in the Git repo'
  task :git => [:authors, :changelog] do
    sh("git checkout master")

    sh("git add guide/AUTHORS")
    sh("git add guide/CHANGELOG")
    sh("git commit -m '#{message}' --sign")
    sh("git tag -a -m '#{message}' #{GEMSPEC.version}")

    sh("git push origin master")
    sh("git push origin : #{GEMSPEC.version}")
  end

  desc 'Pushes a new release to Rubygems'
  task :rubygems => :gem do
    name = "#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
    gem  = File.expand_path("../../pkg/#{name}", __FILE__)

    puts "About to push #{GEMSPEC.name} version #{GEMSPEC.version}"
    print 'Are you really sure you want to continue? y/n: '

    confirmed = STDIN.gets
    confirmed = confirmed.strip if confirmed

    if !confirmed or confirmed != 'y'
      abort 'Aborting'
    end

    unless File.file?(gem)
      abort "The gem #{name} does not exist, you can build it using `rake gem`"
    end

    sh("gem push #{gem}")
  end
end
