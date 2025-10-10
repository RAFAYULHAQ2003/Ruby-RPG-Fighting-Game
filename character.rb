# frozen_string_literal: true

require 'securerandom'
require 'json'
require_relative 'logger_module'

# Abstract base class for all characters.
class Character
  attr_accessor :id, :name, :class_type, :level, :experience, :health, :attack, :defense

  def initialize(name:, base_stats:, id: nil, level: 1, experience: 0)
    @id = id || SecureRandom.uuid
    @name = name
    @class_type = self.class.name
    @level = level
    @experience = experience

    @health  = base_stats['health']
    @attack  = base_stats['attack']
    @defense = base_stats['defense']
  end

  # ---- JSON Serialization ----
  def to_json(*_args)
    {
      id: @id,
      name: @name,
      class_type: @class_type,
      level: @level,
      experience: @experience,
      health: @health,
      attack: @attack,
      defense: @defense
    }.to_json
  end

  def self.from_json(json_str)
    data = JSON.parse(json_str)
    klass = Object.const_get(data['class_type'])
    klass.new(
      name: data['name'],
      id: data['id'],
      level: data['level'],
      experience: data['experience'],
      base_stats: { 'health' => data['health'], 'attack' => data['attack'], 'defense' => data['defense'] }
    )
  end

  def gain_xp(amount)
    @experience += amount
    check_level_up
  end

  def xp_needed_for_next_level
    @level * 100
  end

  def check_level_up
    leveled = false
    while @experience >= xp_needed_for_next_level
      @experience -= xp_needed_for_next_level
      @level += 1
      leveled = true
    end
    [leveled, @level]
  end

  # ---- Helpers ----
  def stats_str
    "HP: #{@health} | ATK: #{@attack} | DEF: #{@defense}"
  end

  def ident
    "#{@name} #{@id}"
  end

  def alive?
    @health.positive?
  end
end
