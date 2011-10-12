desc 'Generate YARD documentation'
task :yard => :setup do
  sh('yard doc')
end
