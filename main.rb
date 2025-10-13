# frozen_string_literal: true

require_relative 'characters/warrior'
require_relative 'characters/mage'
require_relative 'characters/rogue'
require_relative 'enemy'
require_relative 'combat_engine'
require_relative 'save_manager'
require_relative 'logger_module'

def clear_screen
  system('clear')
end

def prompt_main_menu
  puts 'Welcome to Legends of the Ruby Realm!!'
  puts '1. Start New Game'
  puts '2. Load Game'
  puts '3. Exit'
  print '> '
  gets.chomp
end

def choose_class
  puts 'Choose class:'
  character_classes = Character.subclasses
  list_classes(character_classes)
  pick_class(character_classes)
end

def list_classes(classes)
  classes.each_with_index { |klass, i| puts "#{i + 1}. #{klass.name}" }
end

def pick_class(classes)
  loop do
    print '> '
    idx = $stdin.gets&.chomp.to_i
    return classes[idx - 1] if idx.between?(1, classes.size)

    puts 'Invalid selection. Choose a valid class number.'
  end
end

def prompt_for_name
  loop do
    print 'Enter your name: '
    name = $stdin.gets&.chomp

    return name unless name.nil? || name.strip.empty?

    puts 'Please enter a valid name.'
  end
end

def create_new_character
  name = prompt_for_name
  klass = choose_class
  char = klass.new(name: name)
  puts "You are #{char.name} the #{char.class_type}! (ID: #{char.id})"
  LoggerModule.log("Created new character: #{char.ident} (class #{char.class_type}).")
  char
end

def load_character_flow
  saves = SaveManager.list_saves
  return no_saves_found if saves.empty?

  display_saves(saves)
  choose_save(saves)
end

def no_saves_found
  puts 'No save files found.'
  nil
end

def display_saves(saves)
  puts 'Available saves:'
  saves.each_with_index { |s, i| puts "#{i + 1}. #{s}" }
  puts "#{saves.size + 1}. Cancel"
end

def choose_save(saves)
  loop do
    print '> '
    idx = $stdin.gets.to_i
    return nil if idx == saves.size + 1

    return try_load_save(saves[idx - 1]) if (1..saves.size).cover?(idx)

    puts 'Invalid selection.'
  end
end

def try_load_save(path)
  char = SaveManager.load_from_file(path)
  puts "Loaded #{char.name} (Level #{char.level})"
  LoggerModule.log("Loaded character #{char.ident} from #{path}.")
  char
rescue StandardError => e
  puts "Failed to load save: #{e.message}"
  nil
end

def game_loop(character)
  loop do
    result = start_battle(character)
    break if handle_battle_result(result, character)
  end
end

def start_battle(character)
  enemy = CombatEngine.random_enemy_for(character)
  engine = CombatEngine.new(character)
  engine.fight(enemy)
end

def handle_battle_result(result, character)
  case result
  when :won then post_battle_menu(character)
  when :ran then puts 'You live to fight another day...'
  when :lost
    puts "Game over for #{character.name}."
    return true
  end
  !continue_exploring?
end

def continue_exploring?
  puts 'Continue exploring? (y/n)'
  print '> '
  %w[y yes].include?($stdin.gets&.chomp&.downcase)
end

def post_battle_menu(character)
  loop do
    print "\nSave progress? (y/n): "
    input = $stdin.gets&.chomp&.downcase
    return if %w[n no].include?(input)

    if %w[y yes].include?(input)
      SaveManager.save(character)
      return
    end
    puts 'Please answer y or n.'
  end
end

def run
  LoggerModule.ensure_log
  loop do
    clear_screen
    handle_menu_choice(prompt_main_menu)
    puts 'Press Enter to return to main menu...'
    $stdin.gets
  end
end

def handle_menu_choice(choice)
  case choice
  when '1' then start_new_game
  when '2' then load_game_flow
  when '3' then exit_game
  else
    puts 'Invalid option. Try again.'
  end
end

def start_new_game
  char = create_new_character
  game_loop(char)
end

def load_game_flow
  char = load_character_flow
  game_loop(char) if char
end

def exit_game
  puts 'Goodbye!'
  exit
end

run if __FILE__ == $PROGRAM_NAME
