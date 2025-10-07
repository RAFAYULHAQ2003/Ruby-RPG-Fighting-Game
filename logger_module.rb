# frozen_string_literal: true

require 'time'
require 'fileutils'

# Logger module that logs each step or activity in battle_log file
module LoggerModule
  LOG_FILE = 'battle_log.txt'

  # Ensure log file exists
  def self.ensure_log
    FileUtils.touch(LOG_FILE) unless File.exist?(LOG_FILE)
  end

  def self.log(message)
    ensure_log
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    File.open(LOG_FILE, 'a') do |f|
      f.puts("[#{timestamp}] #{message}")
    end
  rescue StandardError => e
    puts "Logging error: #{e.message}"
  end
end
