require 'rubygems'
require 'bundler/setup'

require 'yaml'

require 'updater'


config_location = File.join(File.dirname(__FILE__), 'config.yml')

config = YAML.load_file(config_location)[:autodrive]

updater = AutoDriver::Updater.new('latest-binary' => config['latest-binary'], 'arguments' => config['arguments'])
updater.start

STDIN.gets
updater.stop
