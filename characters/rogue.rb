# frozen_string_literal: true

require_relative '../character'

# Agile fighter with balanced stats
class Rogue < Character
  BASE_STATS = {
    'health' => 100,
    'attack' => 18,
    'defense' => 10
  }.freeze

  def initialize(**args)
    super(**{ base_stats: BASE_STATS }.merge(args))
  end
end
