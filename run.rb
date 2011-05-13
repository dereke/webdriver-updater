require 'rubygems'
require 'bundler/setup'

require 'webdriver_updater'

webdriver = WebdriverUpdater::Webdriver.new
webdriver.start
