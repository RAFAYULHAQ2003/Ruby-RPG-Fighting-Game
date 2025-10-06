# frozen_string_literal: true

require_relative '../character'

# Powerful spellcaster with high attack but low defense
class Mage < Character
  BASE_STATS = {
    'health' => 80,
    'attack' => 25,
    'defense' => 8
  }.freeze

  def initialize(**args)
    super(**args.merge(class_type: 'Mage'))
  end
end
