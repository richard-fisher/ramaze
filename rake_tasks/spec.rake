#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rake'
require 'pp'

require 'lib/ramaze/snippets/divide'
require 'lib/ramaze/snippets/string/color'

desc 'Run all specs'
task 'spec' do
  require 'scanf'

  root = File.expand_path(File.dirname(__FILE__)/'..')

  specs = Dir[root/'spec/{ramaze,examples,snippets,contrib}/**/*.rb'] +
    Dir[root/'examples/**/spec/**/*.rb']

  ignore = [
    root/'spec/ramaze/adapter.rb', root/'spec/ramaze/request.rb',
  ].map{|i| Dir[i].map{|f| File.expand_path(f) }}.flatten

  config = RbConfig::CONFIG
  bin = config['bindir']/config['ruby_install_name']

  result_format = '%d tests, %d assertions, %d failures, %d errors'

  list = (specs - ignore).sort
  names = list.map{|l| l.sub(root + '/', '') }
  width = names.sort_by{|s| s.size}.last.size
  total = names.size

  list.zip(names).each_with_index do |(spec, name), idx|
    print '%2d/%d: ' % [idx + 1, total]
    print name.ljust(width + 2)

    stdout = `#{bin} #{spec} 2>&1`

    status = $?.exitstatus
    tests, assertions, failures, errors = stdout[/.*\Z/].to_s.scanf(result_format)

    if stdout =~ /Usually you should not worry about this failure, just install the/
      lib = stdout[/^no such file to load -- (.*?)$/, 1] ||
            stdout[/RubyGem version error: (.*)$/, 1]
      puts "requires #{lib}".yellow
    elsif status == 0
      puts "all %3d passed".green % tests
    else
      out = result_format % [tests, assertions, failures, errors]
      puts out.red
      puts stdout
      exit status
    end
  end

  puts '', "joy: the emotion evoked by well-being, success, or good fortune or by the
prospect of possessing what one desires"
  puts "All specs pass, go enjoy yourself :)"
end
