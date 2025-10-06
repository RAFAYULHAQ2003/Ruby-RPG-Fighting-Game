# frozen_string_literal: true

require_relative '../character'

# Strong melee fighter class
class Warrior < Character
  BASE_STATS = {
    'health' => 120,
    'attack' => 20,
    'defense' => 15
  }.freeze

  def initialize(**args)
    super(**{ base_stats: BASE_STATS }.merge(args))
  end
end
