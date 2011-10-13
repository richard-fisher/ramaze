desc 'Generate YARD documentation'
task :yard => :setup do
  path = File.expand_path('../../doc', __FILE__)

  sh("rm -rf #{path}")
  sh('yard doc')
end
