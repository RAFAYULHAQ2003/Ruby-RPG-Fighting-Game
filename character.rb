# frozen_string_literal: true

require 'securerandom'
require 'yaml'
require_relative 'logger_module'

# Abstract base class for all characters.
class Character
  attr_accessor :id, :name, :class_type, :level, :xp, :stats, :current_hp

  def initialize(name:, class_type:, id: nil, level: 1, xp: 0, stats: nil, current_hp: nil)
    @id = id || SecureRandom.uuid
    @name = name
    @class_type = class_type
    @level = level
    @xp = xp
    @stats = stats || self.class::BASE_STATS.dup
    @current_hp = current_hp || @stats['health']
  end

  def to_hash
    {
      'id' => @id,
      'name' => @name,
      'class' => @class_type,
      'level' => @level,
      'xp' => @xp,
      'stats' => @stats,
      'current_hp' => @current_hp
    }
  end

  def gain_xp(amount)
    @xp += amount
    LoggerModule.log("Player #{@id} gained #{amount} XP (total #{@xp}).")
    check_level_up
  end

  def xp_needed_for_next_level
    @level * 100
  end

  def check_level_up
    leveled = false
    while @xp >= xp_needed_for_next_level
      @xp -= xp_needed_for_next_level
      @level += 1
      leveled = true
      
    end
    leveled
  end

  

  def stats_str
    "HP: #{@stats['health']} | ATK: #{@stats['attack']} | DEF: #{@stats['defense']}"
  end

  def ident
    "#{@name} #{@id}"
  end

  def health
    @current_hp
  end

  def health=(value)
    @current_hp = value
  end

  def defense
    @stats['defense']
  end

  def defense=(value)
    @stats['defense'] = value
  end

  def attack
    @stats['attack']
  end

  def alive?
    @current_hp > 0
  end
end
