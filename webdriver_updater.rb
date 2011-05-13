
require 'fssm'

module WebdriverUpdater

  WEB_DRIVER_PATH = "build/java/server/src/org/openqa/selenium/server/"
  EXECUTABLE_NAME = "server-standalone.jar"

  ENV['WEBDRIVER_LATEST'] = ENV['WEBDRIVER_LATEST'] || "e:/#{WEB_DRIVER_PATH}#{EXECUTABLE_NAME}"

  class Webdriver
    SERVICE_NAME = "Webdriver Updater"

    def update
      puts "Updating webdriver binaries"
      FileUtils.mkdir webdriver_folder if not File.exists? webdriver_folder
      FileUtils.cp_r ENV['WEBDRIVER_LATEST'], webdriver_folder + EXECUTABLE_NAME
    end

    def start
      monitor
      run
      puts "Running... press any key to exit"
      STDIN.gets
      stop
    end

    def stop
      puts "Stopping..."
      Process.kill 9, @status.pid
      puts "Stopped"
    end

    def run
      puts "Starting webdriver on a new thread"
      Thread.new do
        @status = IO.popen("\"#{java_binary}\" -jar \"#{make_path_windows_friendly(webdriver_folder+EXECUTABLE_NAME)}\"") 
      end
      puts "Webdriver running with pid: #{@status.pid}"
    end

    def monitor
      thread = Thread.new do
        folder_parts = ENV['WEBDRIVER_LATEST'].split('/')
        folder_parts.pop
        webdriver = self
        FSSM.monitor(folder_parts.join('\\'), EXECUTABLE_NAME) do
          create {|base, relative|
          webdriver.stop
          webdriver.update
          webdriver.run
          }
        end
      end
    end

    def java_binary
      make_path_windows_friendly "C:/Program Files (x86)/Java/jre6/bin/java.exe"
    end

    def webdriver_folder
      File.expand_path(File.dirname(__FILE__)) + "/bin/"
      #"c:/bin/"
    end

    def make_path_windows_friendly(path)
      path.gsub('/', '\\')
    end
  end
end
