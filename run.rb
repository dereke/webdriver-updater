require 'rubygems'
require 'bundler/setup'

require 'fssm'

raise "You must supply only one argument" if ARGV.length != 1

class Service
  SERVICE_NAME = "Webdriver Updater"
  def install
    system("sc create \"#{SERVICE_NAME}\" binPath=\"java -jar webdriver.jar\"")
  end

  def start
    system("sc start \"#{SERVICE_NAME}\"")
  end

  def stop
    system("sc stop \"#{SERVICE_NAME}\"")
  end

  def monitor
    FSSM.monitor('c:/projects/mon/', 'test.txt') do
      update {|base, relative|
        stop
        get_updated_webdriver
        start
      }
    end
  end

  private
  def get_updated_webdriver
    raise "not implemented!"
  end
end

service = Service.new
service.send(ARGV.first.to_sym)