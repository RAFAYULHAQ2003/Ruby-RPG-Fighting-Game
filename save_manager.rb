# frozen_string_literal: true

require 'json'
require_relative 'logger_module'
require_relative 'characters/warrior'
require_relative 'characters/mage'
require_relative 'characters/rogue'

# To save serilized or deserilized in json file
class SaveManager
  SAVE_DIR = 'saves'

  def self.ensure_dir
    Dir.mkdir(SAVE_DIR) unless Dir.exist?(SAVE_DIR)
  end

  def self.save(character)
    ensure_dir
    path = File.join(SAVE_DIR, "#{character.name}_#{character.id}.json")
    File.write(path, character.to_json)
    puts "Game saved to #{path}"
    LoggerModule.log("Saved character #{character.ident} to #{path}")
  end

  def self.list_saves
    ensure_dir
    Dir.glob(File.join(SAVE_DIR, '*.json')).map { |f| File.basename(f) }
  end

  def self.load_from_file(filename)
    ensure_dir
    path = File.join(SAVE_DIR, filename)
    json_data = File.read(path)
    character = Character.from_json(json_data)
    LoggerModule.log("Loaded #{character.ident} from #{path}")
    character
  end
end
