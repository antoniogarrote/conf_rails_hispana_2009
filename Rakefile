# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

CASSANDRA_HOME = "/usr/local/cassandra"
CASSANDRA_DATA = "/var/lib/cassandra"

desc "Start Cassandra"
task :cassandra do
  # Construct environment
  env = ""
  env << "CASSANDRA_INCLUDE=#{Dir.pwd}/config/cassandra/cassandra.in.sh "
  env << "CASSANDRA_HOME=#{CASSANDRA_HOME} "
  env << "CASSANDRA_CONF=#{Dir.pwd}/config/cassandra "
  # Start server
  Dir.chdir(CASSANDRA_DATA) do
    exec("env #{env} #{CASSANDRA_HOME}/bin/cassandra -f")
  end
end