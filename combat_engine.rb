# frozen_string_literal: true

require_relative 'logger_module'
require_relative 'enemy'

# Handles combat between player and enemy with layered defense logic.
class CombatEngine
  def initialize(player)
    @player = player
  end

  def self.random_enemy_for(player)
    types = Enemy::ENEMY_TYPES.keys
    chosen = types.sample
    enemy_level = [1, player.level + [-1, 0, 1, 2, 3].sample].max
    Enemy.new(type: chosen, level: enemy_level)
  end

  def fight(enemy)
    announce_enemy(enemy)
    LoggerModule.log("Encounter started: Player #{@player.id} vs #{enemy.ident} (lvl #{enemy.level}).")

    while both_alive?(enemy)
      display_status(enemy)
      result = handle_player_action(enemy)
      return result if %i[won ran lost].include?(result)
    end

    handle_defeat(enemy)
  end

  def announce_enemy(enemy)
    puts "\nA wild #{enemy.name} (Level #{enemy.level}) appears!"
  end

  def both_alive?(enemy)
    enemy.alive? && @player.alive?
  end

  def handle_player_action(enemy)
    case player_choice
    when :attack then perform_attack(@player, enemy)
    when :defend then defend_and_counter(enemy)
    when :run    then attempt_escape(enemy)
    end
  end

  def defend_and_counter(enemy)
    puts 'You brace yourself to take the hit.'
    LoggerModule.log("Player #{@player.id} defends.")
    enemy_attack(enemy)
    nil
  end

  def attempt_escape(enemy)
    if try_escape?
      puts 'You escaped successfully!'
      LoggerModule.log("Player #{@player.id} ran from #{enemy.ident}.")
      :ran
    else
      puts 'Escape failed!'
      LoggerModule.log("Player #{@player.id} failed to escape #{enemy.ident}.")
      enemy_attack(enemy)
      nil
    end
  end

  def handle_defeat(enemy)
    return unless @player.health <= 0

    puts 'You have been defeated...'
    LoggerModule.log("Player #{@player.id} was defeated by #{enemy.ident}.")
    :lost
  end

  private

  def display_status(enemy)
    puts "\nYour HP: #{@player.health} | ATT: #{@player.attack} | DEF: #{@player.defense}"
    puts "#{enemy.name} HP: #{enemy.health} | ATT: #{enemy.attack} | DEF: #{enemy.defense}"
    puts 'Choose action:'
    puts '1. Attack'
    @can_defend = @player.defense.positive?
    puts '2. Defend' if @can_defend
    puts '3. Run'
  end

  def player_choice
    loop do
      print '> '
      input = $stdin.gets&.chomp
      next unless input

      next if input == '2' && !@can_defend

      result = options(input)
      return result if result
    end
  end

  def options(opt)
    case opt
    when '1' then :attack
    when '2' then :defend
    when '3' then :run
    else
      puts 'Invalid choice. Enter 1, 2 or 3.'
      nil
    end
  end

  def apply_damage(target, damage)
    return if damage <= 0

    if target.defense.positive?
      absorb_with_defense(target, damage)
    else
      target.health -= damage
    end
  end

  def absorb_with_defense(target, damage)
    if damage >= target.defense
      target.health -= (damage - target.defense)
      target.defense = 0
    else
      target.defense -= damage
    end
  end

  def perform_attack(attacker, enemy)
    damage = attacker.attack
    apply_damage(enemy, damage)

    puts "You attacked #{enemy.name} for #{damage} damage!"
    LoggerModule.log("Player #{@player.id} attacked #{enemy.ident} for #{damage} damage.")

    return enemy_attack(enemy) if enemy.alive?

    handle_victory(enemy)
    :won
  end

  def handle_victory(enemy)
    reward = enemy.level * 20
    puts "#{enemy.name} defeated! You gained #{reward} XP."
    LoggerModule.log("Enemy #{enemy.ident} defeated by Player #{@player.id}.")
    leveled_up, new_level = @player.gain_xp(reward)
    announce_level_up(new_level) if leveled_up
  end

  def announce_level_up(level)
    message = "Player #{@player.id} (#{@player.name}) reached Level #{level}!"
    puts message
    LoggerModule.log(message)
  end

  def enemy_attack(enemy)
    damage = enemy.attack
    apply_damage(@player, damage)

    puts "#{enemy.name} attacked you for #{damage} damage!"
    LoggerModule.log("#{enemy.ident} attacked Player #{@player.id} for #{damage} damage.")
  end

  def try_escape?
    rand < 0.5
  end
end
