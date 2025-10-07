# frozen_string_literal: true

require 'securerandom'

# Enemy represents a game opponent with stats based on type and level.
class Enemy
  ENEMY_TYPES = {
    'Goblin' => { base_health: 50, base_attack: 8, base_defense: 3 },
    'Troll' => { base_health: 120, base_attack: 15, base_defense: 8 },
    'Dragon' => { base_health: 300, base_attack: 30, base_defense: 20 }
  }.freeze

  attr_accessor :id, :name, :level, :health, :attack, :defense

  def initialize(type:, level:)
    @id = SecureRandom.uuid
    @name = type
    @level = level
    
     @health, @attack, @defense = ENEMY_TYPES[type].values_at(:base_health, :base_attack, :base_defense)
  end

  def ident
    "#{@name} #{@id}"
  end

  def alive?
    @health.positive?
  end

  def take_damage(amount)
    @health -= amount
    @health = 0 if @health.negative?
  end
end
