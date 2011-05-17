require 'directory_watcher'
require 'selenium/server'
# dodgy - loading webdriver to get Dir.mktmpdir method in 1.8.7
require 'selenium-webdriver'

module AutoDriver
  class Updater

    def initialize(options)
      @latest_binary = options.delete('latest-binary')
      @executable_name = @latest_binary.split('/').last
    end

    def update
      FileUtils.mkdir @execute_in_folder if not File.exists? @execute_in_folder
      FileUtils.cp_r @latest_binary, File.join(@execute_in_folder,  @executable_name)
    end

    def start
      @execute_in_folder = Dir.mktmpdir
      update
      @server = Selenium::Server.new(File.join(@execute_in_folder, @executable_name), :background => true)
      @monitor_thread = Thread.new do
        folder_parts = @latest_binary.split('/')
        folder_parts.pop
        updater = self
        server = @server

        dw = DirectoryWatcher.new folder_parts.join('/')

        dw.interval = 1.0
        dw.glob = @executable_name
        dw.reset true

        dw.add_observer {|*args| args.each {|event|
          if event.type == :added or event.type == :modified
            puts "Webdriver going down for update"
            server.stop
            puts "Updating to latest version"
            updater.update
            puts "Webdriver restarting after update"
            server.start
          end
          }
        }
        dw.start
      end
      @server.start
      puts "AutoDriver started"
    end

    def stop
      @server.stop
      @monitor_thread.kill if not @monitor_thread.nil?
      FileUtils.rm_rf @execute_in_folder if not @execute_in_folder.nil?
      puts "AutoDriver stopped"
    end
  end
end
